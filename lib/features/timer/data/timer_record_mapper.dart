import 'dart:convert';

import 'package:drift/drift.dart';
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
      timeoutBehavior: _timeoutBehaviorFromName(row.timeoutBehavior),
    );
    _validateConfig(config);
    final phase = _timerPhase(row.phase);
    if (phase != TimerPhase.idle && row.deadlineAtUtc == null) {
      throw const FormatException('Active timer snapshot has no deadline');
    }
    return TimerSnapshot(
      cycleId: row.cycleId,
      revision: row.revision,
      phase: phase,
      executionStatus: _executionStatus(row.executionStatus),
      startedAtUtc: row.startedAtUtc.toUtc(),
      deadlineAtUtc: row.deadlineAtUtc?.toUtc(),
      nextReminderAtUtc: row.nextReminderAtUtc?.toUtc(),
      cycleConfig: config,
    );
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
      timeoutBehavior: Value(snapshot.cycleConfig.timeoutBehavior.name),
    );
  }

  static String commandKind(TimerCommand command) => switch (command) {
    StartWorkCommand() => 'startWork',
    StartRestCommand() => 'startRest',
    SuspendTimerCommand() => 'suspendTimer',
    ResumeTimerCommand() => 'resumeTimer',
    SkipRestCommand() => 'skipRest',
    StopTimerCommand() => 'stopTimer',
    ReachDeadlineCommand() => 'reachDeadline',
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
      case SkipRestCommand value:
        payload['nextCycleId'] = value.nextCycleId;
        payload['nextCycleConfig'] = _configToJson(value.nextCycleConfig);
      case StopTimerCommand():
        break;
      case ReachDeadlineCommand value:
        payload['nextCycleId'] = value.nextCycleId;
        payload['nextCycleConfig'] = _configToJson(value.nextCycleConfig);
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
      'skipRest' => SkipRestCommand(
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
      'reachDeadline' => ReachDeadlineCommand(
        commandId: common.commandId,
        occurredAtUtc: common.occurredAtUtc,
        nextCycleId: payload['nextCycleId']! as String,
        nextCycleConfig: _configFromJson(payload['nextCycleConfig']),
        expectedCycleId: common.expectedCycleId,
        expectedPhase: common.expectedPhase,
        expectedRevision: common.expectedRevision,
      ),
      'reconcileTimer' => ReconcileTimerCommand(
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
      localDateKey: Value(_localDateKey(localDate)),
      durationMs: Value(duration.inMilliseconds),
      countValue: Value(countValue),
    );
  }

  static String _localDateKey(DateTime local) {
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  static Map<String, Object?> _configToJson(TimerCycleConfig config) {
    return {
      'workDurationMs': config.workDuration.inMilliseconds,
      'restDurationMs': config.restDuration.inMilliseconds,
      'reminderIntervalMs': config.reminderInterval.inMilliseconds,
      'reminderTimeoutMs': config.reminderTimeout.inMilliseconds,
      'timeoutBehavior': config.timeoutBehavior.name,
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
      timeoutBehavior: _timeoutBehaviorFromJson(map['timeoutBehavior']),
    );
    _validateConfig(config);
    return config;
  }

  static TimeoutBehavior _timeoutBehaviorFromJson(Object? value) {
    final name = value as String?;
    return _timeoutBehaviorFromName(name);
  }

  static TimeoutBehavior _timeoutBehaviorFromName(String? value) {
    return value == 'stopTimer'
        ? TimeoutBehavior.stopTimer
        : TimeoutBehavior.nextCycle;
  }

  static TimerPhase _timerPhase(String value) => switch (value) {
    'idle' => TimerPhase.idle,
    'working' => TimerPhase.working,
    'awaitingRest' => TimerPhase.awaitingRest,
    'resting' => TimerPhase.resting,
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
        config.reminderTimeout <= config.reminderInterval) {
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
