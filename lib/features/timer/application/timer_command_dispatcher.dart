import 'dart:async';

import 'package:rest_eye/core/async/serial_operation_queue.dart';
import 'package:rest_eye/core/clock/app_clock.dart';
import 'package:rest_eye/core/logging/app_logger.dart';
import 'package:rest_eye/features/settings/domain/settings_repository.dart';
import 'package:rest_eye/features/timer/application/notification_schedule_reconciler.dart';
import 'package:rest_eye/features/timer/application/timer_cycle_config_factory.dart';
import 'package:rest_eye/features/timer/domain/timer_command.dart';
import 'package:rest_eye/features/timer/domain/timer_reducer.dart';
import 'package:rest_eye/features/timer/domain/timer_repository.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';
import 'package:rest_eye/features/timer/domain/timer_transition.dart';

final class TimerCommandDispatcher {
  TimerCommandDispatcher(
    this._repository,
    this._settingsRepository,
    this._clock,
    this._logger,
    this._notificationReconciler,
  );

  final TimerRepository _repository;
  final SettingsRepository _settingsRepository;
  final AppClock _clock;
  final AppLogger _logger;
  final NotificationScheduleReconciler? _notificationReconciler;
  final _snapshots = StreamController<TimerSnapshot>.broadcast();
  final _queue = SerialOperationQueue();
  TimerSnapshot _current = TimerSnapshot.idle();
  var _idCounter = 0;

  TimerSnapshot get current => _current;
  Stream<TimerSnapshot> get snapshots => _snapshots.stream;

  String createId(String prefix) {
    return '$prefix-${_clock.utcNow.microsecondsSinceEpoch}-${_idCounter++}';
  }

  Future<void> initialize() async {
    _current = await _repository.loadSnapshot();
    _snapshots.add(_current);
  }

  Future<TimerTransition> dispatch(
    TimerCommand command, {
    bool fromInbox = false,
    bool skipPreReconcile = false,
    bool preservePreviousNotifications = true,
    DateTime? maxReconcileAtUtc,
  }) {
    return _queue.run(
      () => _execute(
        command,
        fromInbox: fromInbox,
        skipPreReconcile: skipPreReconcile,
        preservePreviousNotifications: preservePreviousNotifications,
        maxReconcileAtUtc: maxReconcileAtUtc,
      ),
      onError: (Object error, StackTrace stackTrace) {
        _logger.error(
          'Timer command failed',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  Future<void> recover() async {
    final pending = await _repository.loadPendingCommands();
    for (final command in pending) {
      await dispatch(command, fromInbox: true);
    }
    final settings = await _settingsRepository.load();
    await dispatch(
      ReconcileTimerCommand(
        commandId: createId('recover'),
        occurredAtUtc: _clock.utcNow,
        nextCycleId: createId('cycle'),
        nextCycleConfig: timerCycleConfigFromSettings(settings),
      ),
    );
    await _notificationReconciler?.reconcile(_current);
  }

  Future<TimerSnapshot> refreshFromRepository() {
    return _queue.run(
      () async {
        final durable = await _repository.loadSnapshot();
        if (durable.revision != _current.revision ||
            durable.cycleId != _current.cycleId) {
          _publish(durable);
        }
        return durable;
      },
      onError: (Object error, StackTrace stackTrace) {
        _logger.error(
          'Timer snapshot refresh failed',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  Future<void> stopIfActive({
    required String source,
    DateTime? occurredAtUtc,
  }) async {
    // The Android notification action handler can run in a background isolate
    // and commit a newer snapshot to the shared database. Do not make a
    // shutdown decision from this isolate's cached snapshot.
    final durable = await refreshFromRepository();
    if (!durable.isActive) return;
    await _stopActive(
      durable,
      source: source,
      occurredAtUtc: occurredAtUtc ?? _clock.utcNow,
    );
  }

  Future<void> stopAbandonedTimer({required String source}) async {
    final durable = await refreshFromRepository();
    if (!durable.isActive) return;
    await _stopActive(
      durable,
      source: source,
      occurredAtUtc: durable.startedAtUtc,
      cancelPreviousNotifications: true,
    );
  }

  Future<void> _stopActive(
    TimerSnapshot durable, {
    required String source,
    required DateTime occurredAtUtc,
    bool cancelPreviousNotifications = false,
  }) async {
    final now = _clock.utcNow;
    var stoppedAt = occurredAtUtc;
    if (stoppedAt.isBefore(durable.startedAtUtc)) {
      stoppedAt = durable.startedAtUtc;
    }
    if (stoppedAt.isAfter(now)) stoppedAt = now;
    await dispatch(
      StopTimerCommand(
        commandId: createId('stop-$source'),
        occurredAtUtc: stoppedAt,
      ),
      skipPreReconcile: cancelPreviousNotifications,
      preservePreviousNotifications: !cancelPreviousNotifications,
    );
  }

  Future<TimerTransition> _execute(
    TimerCommand command, {
    required bool fromInbox,
    required bool skipPreReconcile,
    required bool preservePreviousNotifications,
    required DateTime? maxReconcileAtUtc,
  }) async {
    final settings = await _settingsRepository.load();
    var durable = await _repository.loadSnapshot();

    if (!skipPreReconcile &&
        command is! ReconcileTimerCommand &&
        durable.isActive) {
      final reconcileAt = _earlierUtc(command.occurredAtUtc, maxReconcileAtUtc);
      final preReconcile = ReconcileTimerCommand(
        commandId: '${command.commandId}:pre',
        occurredAtUtc: reconcileAt,
        nextCycleId: '${command.commandId}:cycle',
        nextCycleConfig: timerCycleConfigFromSettings(settings),
      );
      final preTransition = TimerReducer.reduce(durable, preReconcile);
      if (preTransition.outcome == TimerTransitionOutcome.applied) {
        final committed = await _commitWithOneRetry(
          previous: durable,
          command: preReconcile,
          transition: preTransition,
        );
        durable = committed.snapshot;
        _publish(durable);
      }
    }

    final transition = TimerReducer.reduce(durable, command);
    if (transition.outcome == TimerTransitionOutcome.ignored) {
      _logScreenPauseCommandResult(command, transition);
      if (fromInbox) {
        await _repository.markCommandStale(command.commandId, _clock.utcNow);
      }
      await _notificationReconciler?.reconcile(durable);
      return transition;
    }

    final committed = await _commitWithOneRetry(
      previous: durable,
      command: command,
      transition: transition,
      processedCommandId: fromInbox ? command.commandId : null,
    );
    if (committed.outcome == TimerTransitionOutcome.ignored) {
      _logScreenPauseCommandResult(command, committed);
      if (fromInbox) {
        await _repository.markCommandStale(command.commandId, _clock.utcNow);
      }
      return committed;
    }
    _publish(committed.snapshot);
    _logScreenPauseCommandResult(command, committed);
    await _notificationReconciler?.reconcile(
      committed.snapshot,
      previousSnapshot: preservePreviousNotifications ? durable : null,
    );
    return committed;
  }

  DateTime _earlierUtc(DateTime first, DateTime? second) {
    final firstUtc = first.toUtc();
    final secondUtc = second?.toUtc();
    if (secondUtc == null || firstUtc.isBefore(secondUtc)) return firstUtc;
    return secondUtc;
  }

  void _logScreenPauseCommandResult(
    TimerCommand command,
    TimerTransition transition,
  ) {
    if (command is! SuspendTimerCommand && command is! ResumeTimerCommand) {
      return;
    }
    _logger.info(
      'Screen pause command result: command=${command.runtimeType}; '
      'outcome=${transition.outcome}; '
      'phase=${transition.snapshot.phase}; '
      'executionStatus=${transition.snapshot.executionStatus}; '
      'revision=${transition.snapshot.revision}; '
      'remainingMs=${transition.snapshot.remainingAt(_clock.utcNow).inMilliseconds}',
    );
  }

  Future<TimerTransition> _commitWithOneRetry({
    required TimerSnapshot previous,
    required TimerCommand command,
    required TimerTransition transition,
    String? processedCommandId,
  }) async {
    try {
      await _repository.commit(
        expectedRevision: previous.revision,
        snapshot: transition.snapshot,
        events: transition.events,
        processedCommandId: processedCommandId,
        processedAtUtc: processedCommandId == null ? null : _clock.utcNow,
      );
      return transition;
    } on TimerCommitConflict {
      final fresh = await _repository.loadSnapshot();
      final retried = TimerReducer.reduce(fresh, command);
      if (retried.outcome == TimerTransitionOutcome.ignored) return retried;
      await _repository.commit(
        expectedRevision: fresh.revision,
        snapshot: retried.snapshot,
        events: retried.events,
        processedCommandId: processedCommandId,
        processedAtUtc: processedCommandId == null ? null : _clock.utcNow,
      );
      return retried;
    }
  }

  void _publish(TimerSnapshot snapshot) {
    _current = snapshot;
    _snapshots.add(snapshot);
  }

  Future<void> dispose() async {
    await _queue.idle;
    await _snapshots.close();
  }
}
