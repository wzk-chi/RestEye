import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:rest_eye/core/clock/local_date_key.dart';
import 'package:rest_eye/features/timer/domain/timer_command.dart';
import 'package:rest_eye/features/timer/domain/timer_event.dart';
import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/features/timer/domain/timer_policy.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';
import 'package:rest_eye/infrastructure/database/app_database.dart';

abstract final class TimerRecordMapper {
  static TimerSnapshot snapshotFromRow(TimerSnapshotRow row) {
    final config = TimerCycleConfig(
      workDuration: Duration(milliseconds: row.workDurationMs),
      restDuration: Duration(milliseconds: row.restDurationMs),
      reminderInterval: Duration(milliseconds: row.reminderIntervalMs),
      reminderTimeout: Duration(milliseconds: row.reminderTimeoutMs),
      missedWorkReminderInterval: Duration(
        milliseconds: row.missedWorkReminderIntervalMs,
      ),
      restTimeout: Duration(milliseconds: row.restTimeoutMs),
      timeoutBehavior: _timeoutBehaviorFromName(
        row.timeoutBehavior,
        strict: true,
      ),
      restTimeoutBehavior: _timeoutBehaviorFromName(
        row.restTimeoutBehavior,
        strict: true,
      ),
      restCompletionBehavior: _restCompletionBehaviorFromJson(
        row.restCompletionBehavior,
        strict: true,
      ),
    );
    _validateConfig(config);
    final phase = _timerPhase(row.phase);
    final snapshot = TimerSnapshot(
      cycleId: row.cycleId,
      revision: row.revision,
      phase: phase,
      executionStatus: _executionStatus(row.executionStatus),
      startedAtUtc: row.startedAtUtc.toUtc(),
      deadlineAtUtc: row.deadlineAtUtc?.toUtc(),
      nextReminderAtUtc: row.nextReminderAtUtc?.toUtc(),
      cycleConfig: config,
    );
    snapshot.validateInvariant();
    return snapshot;
  }

  static TimerSnapshotsTableCompanion snapshotToCompanion(
    TimerSnapshot snapshot,
  ) {
    return TimerSnapshotsTableCompanion(
      id: const Value(1),
      cycleId: Value(snapshot.cycleId),
      revision: Value(snapshot.revision),
      phase: Value(snapshot.phase.name),
      executionStatus: Value(snapshot.executionStatus.name),
      startedAtUtc: Value(snapshot.startedAtUtc.toUtc()),
      deadlineAtUtc: Value(snapshot.deadlineAtUtc?.toUtc()),
      nextReminderAtUtc: Value(snapshot.nextReminderAtUtc?.toUtc()),
      workDurationMs: Value(snapshot.cycleConfig.workDuration.inMilliseconds),
      restDurationMs: Value(snapshot.cycleConfig.restDuration.inMilliseconds),
      reminderIntervalMs: Value(
        snapshot.cycleConfig.reminderInterval.inMilliseconds,
      ),
      reminderTimeoutMs: Value(
        snapshot.cycleConfig.reminderTimeout.inMilliseconds,
      ),
      missedWorkReminderIntervalMs: Value(
        snapshot.cycleConfig.missedWorkReminderInterval.inMilliseconds,
      ),
      restTimeoutMs: Value(snapshot.cycleConfig.restTimeout.inMilliseconds),
      timeoutBehavior: Value(snapshot.cycleConfig.timeoutBehavior.name),
      restTimeoutBehavior: Value(snapshot.cycleConfig.restTimeoutBehavior.name),
      restCompletionBehavior: Value(
        snapshot.cycleConfig.restCompletionBehavior.name,
      ),
    );
  }

  static String commandKind(TimerCommand command) => switch (command) {
    StartWorkCommand() => 'startWork',
    StartRestCommand() => 'startRest',
    SuspendTimerCommand() => 'suspendTimer',
    ResumeTimerCommand() => 'resumeTimer',
    CompleteRestCommand() => 'completeRest',
    StopTimerCommand() => 'stopTimer',
    ReconcileTimerCommand() => 'reconcileTimer',
  };

  static String commandToJson(TimerCommand command) {
    final payload = <String, Object?>{
      'kind': commandKind(command),
      'commandId': command.commandId,
      'occurredAtUtc': command.occurredAtUtc.toUtc().toIso8601String(),
      'expectedCycleId': command.expectedCycleId,
      'expectedPhase': command.expectedPhase?.name,
      'expectedRevision': command.expectedRevision,
    };
    switch (command) {
      case StartWorkCommand value:
        payload['cycleId'] = value.cycleId;
        payload['cycleConfig'] = _configToJson(value.cycleConfig);
      case StartRestCommand():
        break;
      case SuspendTimerCommand():
        break;
      case ResumeTimerCommand():
        break;
      case CompleteRestCommand value:
        payload['nextCycleId'] = value.nextCycleId;
        payload['nextCycleConfig'] = _configToJson(value.nextCycleConfig);
      case StopTimerCommand():
        break;
      case ReconcileTimerCommand value:
        payload['nextCycleId'] = value.nextCycleId;
        payload['nextCycleConfig'] = _configToJson(value.nextCycleConfig);
    }
    return jsonEncode(payload);
  }

  static TimerCommand commandFromRow(PendingCommandRow row) {
    final payload = jsonDecode(row.payloadJson) as Map<String, Object?>;
    final kind = payload['kind']! as String;
    final common = _CommandCommon.fromJson(payload);
    return switch (kind) {
      'startWork' => StartWorkCommand(
        commandId: common.commandId,
        occurredAtUtc: common.occurredAtUtc,
        cycleId: payload['cycleId']! as String,
        cycleConfig: _configFromJson(payload['cycleConfig']),
        expectedCycleId: common.expectedCycleId,
        expectedPhase: common.expectedPhase,
        expectedRevision: common.expectedRevision,
      ),
      'startRest' => StartRestCommand(
        commandId: common.commandId,
        occurredAtUtc: common.occurredAtUtc,
        expectedCycleId: common.expectedCycleId,
        expectedPhase: common.expectedPhase,
        expectedRevision: common.expectedRevision,
      ),
      'suspendTimer' => SuspendTimerCommand(
        commandId: common.commandId,
        occurredAtUtc: common.occurredAtUtc,
        expectedCycleId: common.expectedCycleId,
        expectedPhase: common.expectedPhase,
        expectedRevision: common.expectedRevision,
      ),
      'resumeTimer' => ResumeTimerCommand(
        commandId: common.commandId,
        occurredAtUtc: common.occurredAtUtc,
        expectedCycleId: common.expectedCycleId,
        expectedPhase: common.expectedPhase,
        expectedRevision: common.expectedRevision,
      ),
      // A pre-change inbox row may still contain a skip action. Do not
      // execute that removed behavior after upgrade; safely terminate the
      // current timer instead while preserving inbox recovery.
      'skipRest' => StopTimerCommand(
        commandId: common.commandId,
        occurredAtUtc: common.occurredAtUtc,
        expectedCycleId: common.expectedCycleId,
        expectedPhase: common.expectedPhase,
        expectedRevision: common.expectedRevision,
      ),
      'completeRest' => CompleteRestCommand(
        commandId: common.commandId,
        occurredAtUtc: common.occurredAtUtc,
        nextCycleId: payload['nextCycleId']! as String,
        nextCycleConfig: _configFromJson(payload['nextCycleConfig']),
        expectedCycleId: common.expectedCycleId,
        expectedPhase: common.expectedPhase,
        expectedRevision: common.expectedRevision,
      ),
      'stopTimer' => StopTimerCommand(
        commandId: common.commandId,
        occurredAtUtc: common.occurredAtUtc,
        expectedCycleId: common.expectedCycleId,
        expectedPhase: common.expectedPhase,
        expectedRevision: common.expectedRevision,
      ),
      // 'reachDeadline' is the pre-merge name of the same command shape;
      // keep reading it so inbox rows persisted by older builds still replay.
      'reachDeadline' || 'reconcileTimer' => ReconcileTimerCommand(
        commandId: common.commandId,
        occurredAtUtc: common.occurredAtUtc,
        nextCycleId: payload['nextCycleId']! as String,
        nextCycleConfig: _configFromJson(payload['nextCycleConfig']),
        expectedCycleId: common.expectedCycleId,
        expectedPhase: common.expectedPhase,
        expectedRevision: common.expectedRevision,
      ),
      _ => throw FormatException('Unknown timer command kind: $kind'),
    };
  }

  static List<ActivityEventsTableCompanion> eventToCompanions(
    TimerEvent event,
  ) {
    if (event.duration <= Duration.zero) {
      final local = event.occurredAtUtc.toLocal();
      return [
        _eventCompanion(
          event: event,
          eventId: event.eventId,
          occurredAtUtc: event.occurredAtUtc,
          localDate: local,
          duration: Duration.zero,
          countValue: 0,
        ),
      ];
    }

    final result = <ActivityEventsTableCompanion>[];
    final endUtc = event.occurredAtUtc.toUtc();
    var segmentStartUtc = endUtc.subtract(event.duration);
    var index = 0;
    while (segmentStartUtc.isBefore(endUtc)) {
      final localStart = segmentStartUtc.toLocal();
      final nextMidnightLocal = DateTime(
        localStart.year,
        localStart.month,
        localStart.day + 1,
      );
      final nextMidnightUtc = nextMidnightLocal.toUtc();
      final segmentEndUtc = nextMidnightUtc.isBefore(endUtc)
          ? nextMidnightUtc
          : endUtc;
      final isFinal = !segmentEndUtc.isBefore(endUtc);
      result.add(
        _eventCompanion(
          event: event,
          eventId: '${event.eventId}:$index',
          occurredAtUtc: segmentEndUtc,
          localDate: localStart,
          duration: segmentEndUtc.difference(segmentStartUtc),
          countValue: event.type == TimerEventType.restCompleted && isFinal
              ? 1
              : 0,
        ),
      );
      segmentStartUtc = segmentEndUtc;
      index++;
    }
    return result;
  }

  static ActivityEventsTableCompanion _eventCompanion({
    required TimerEvent event,
    required String eventId,
    required DateTime occurredAtUtc,
    required DateTime localDate,
    required Duration duration,
    required int countValue,
  }) {
    return ActivityEventsTableCompanion(
      eventId: Value(eventId),
      cycleId: Value(event.cycleId),
      eventType: Value(event.type.name),
      occurredAtUtc: Value(occurredAtUtc.toUtc()),
      utcOffsetMinutes: Value(localDate.timeZoneOffset.inMinutes),
      localDateKey: Value(localDateKey(localDate)),
      durationMs: Value(duration.inMilliseconds),
      countValue: Value(countValue),
    );
  }

  static Map<String, Object?> _configToJson(TimerCycleConfig config) {
    return {
      'workDurationMs': config.workDuration.inMilliseconds,
      'restDurationMs': config.restDuration.inMilliseconds,
      'reminderIntervalMs': config.reminderInterval.inMilliseconds,
      'reminderTimeoutMs': config.reminderTimeout.inMilliseconds,
      'missedWorkReminderIntervalMs':
          config.missedWorkReminderInterval.inMilliseconds,
      'restTimeoutMs': config.restTimeout.inMilliseconds,
      'timeoutBehavior': config.timeoutBehavior.name,
      'restTimeoutBehavior': config.restTimeoutBehavior.name,
      'restCompletionBehavior': config.restCompletionBehavior.name,
    };
  }

  static TimerCycleConfig _configFromJson(Object? value) {
    final map = value! as Map<String, Object?>;
    final config = TimerCycleConfig(
      workDuration: Duration(milliseconds: map['workDurationMs']! as int),
      restDuration: Duration(milliseconds: map['restDurationMs']! as int),
      reminderInterval: Duration(
        milliseconds: map['reminderIntervalMs']! as int,
      ),
      reminderTimeout: Duration(milliseconds: map['reminderTimeoutMs']! as int),
      missedWorkReminderInterval: Duration(
        milliseconds:
            map['missedWorkReminderIntervalMs'] as int? ??
            TimerCycleConfig.defaults.missedWorkReminderInterval.inMilliseconds,
      ),
      restTimeout: Duration(
        milliseconds:
            map['restTimeoutMs'] as int? ??
            TimerCycleConfig.defaults.restTimeout.inMilliseconds,
      ),
      timeoutBehavior: _timeoutBehaviorFromJson(map['timeoutBehavior']),
      restCompletionBehavior: _restCompletionBehaviorFromJson(
        map['restCompletionBehavior'],
      ),
    );
    _validateConfig(config);
    return config;
  }

  static TimeoutBehavior _timeoutBehaviorFromJson(Object? value) {
    final name = value as String?;
    return _timeoutBehaviorFromName(name, strict: true);
  }

  static TimeoutBehavior _timeoutBehaviorFromName(
    String? value, {
    bool strict = false,
  }) {
    return switch (value) {
      'stopTimer' => TimeoutBehavior.stopTimer,
      'nextCycle' => TimeoutBehavior.nextCycle,
      _ when !strict => TimeoutBehavior.nextCycle,
      _ => throw FormatException('Unknown timeout behavior: $value'),
    };
  }

  static RestCompletionBehavior _restCompletionBehaviorFromJson(
    Object? value, {
    bool strict = false,
  }) {
    return switch (value as String?) {
      'stopTimer' => RestCompletionBehavior.stopTimer,
      'continueRest' => RestCompletionBehavior.continueRest,
      'startWork' => RestCompletionBehavior.startWork,
      _ when !strict => RestCompletionBehavior.startWork,
      _ => throw FormatException('Unknown rest completion behavior: $value'),
    };
  }

  static TimerPhase _timerPhase(String value) => switch (value) {
    'idle' => TimerPhase.idle,
    'working' => TimerPhase.working,
    'awaitingRest' => TimerPhase.awaitingRest,
    'resting' => TimerPhase.resting,
    'awaitingWork' => TimerPhase.awaitingWork,
    _ => throw FormatException('Unknown timer phase: $value'),
  };

  static ExecutionStatus _executionStatus(String value) => switch (value) {
    'active' => ExecutionStatus.active,
    'suspended' => ExecutionStatus.suspended,
    _ => throw FormatException('Unknown execution status: $value'),
  };

  static void _validateConfig(TimerCycleConfig config) {
    if (config.workDuration <= Duration.zero ||
        config.restDuration <= Duration.zero ||
        config.reminderInterval <= Duration.zero ||
        config.reminderTimeout <= config.reminderInterval ||
        config.missedWorkReminderInterval <= Duration.zero ||
        config.restTimeout <= config.missedWorkReminderInterval) {
      throw const FormatException('Invalid timer cycle configuration');
    }
  }
}

final class _CommandCommon {
  const _CommandCommon({
    required this.commandId,
    required this.occurredAtUtc,
    this.expectedCycleId,
    this.expectedPhase,
    this.expectedRevision,
  });

  factory _CommandCommon.fromJson(Map<String, Object?> json) {
    final expectedPhase = json['expectedPhase'] as String?;
    return _CommandCommon(
      commandId: json['commandId']! as String,
      occurredAtUtc: DateTime.parse(json['occurredAtUtc']! as String).toUtc(),
      expectedCycleId: json['expectedCycleId'] as String?,
      expectedPhase: expectedPhase == null
          ? null
          : TimerRecordMapper._timerPhase(expectedPhase),
      expectedRevision: json['expectedRevision'] as int?,
    );
  }

  final String commandId;
  final DateTime occurredAtUtc;
  final String? expectedCycleId;
  final TimerPhase? expectedPhase;
  final int? expectedRevision;
}
