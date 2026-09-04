import 'package:rest_eye/features/timer/domain/timer_command.dart';
import 'package:rest_eye/features/timer/domain/timer_event.dart';
import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/features/timer/domain/timer_policy.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';
import 'package:rest_eye/features/timer/domain/timer_transition.dart';

abstract final class TimerReducer {
  static TimerTransition reduce(TimerSnapshot current, TimerCommand command) {
    if (_isStale(current, command)) {
      return TimerTransition.ignored(current, TimerIgnoredReason.staleCommand);
    }

    final events = _EventFactory(command.commandId);
    return switch (command) {
      StartWorkCommand value => _startWork(current, value, events),
      StartRestCommand value => _startRest(current, value, events),
      SuspendTimerCommand value => _suspend(current, value, events),
      ResumeTimerCommand value => _resume(current, value, events),
      SkipRestCommand value => _skipRest(current, value, events),
      CompleteRestCommand value => _completeRest(current, value, events),
      StopTimerCommand value => _stop(current, value, events),
      ReconcileTimerCommand value => _reconcile(
        current,
        command: value,
        nextCycleId: value.nextCycleId,
        nextCycleConfig: value.nextCycleConfig,
        events: events,
      ),
    };
  }

  static bool _isStale(TimerSnapshot snapshot, TimerCommand command) {
    final expectedCycleId = command.expectedCycleId;
    if (expectedCycleId != null && expectedCycleId != snapshot.cycleId) {
      return true;
    }
    final expectedPhase = command.expectedPhase;
    if (expectedPhase != null && expectedPhase != snapshot.phase) return true;
    final expectedRevision = command.expectedRevision;
    // Reminder delivery advances the durable revision while the semantic
    // waiting phase and cycle remain the same.  A notification action from
    // that window must stay valid until the phase expires; requiring exact
    // equality would make an older, still-visible reminder button stale as
    // soon as a newer reminder is reconciled.
    return expectedRevision != null && snapshot.revision < expectedRevision;
  }

  static TimerTransition _startWork(
    TimerSnapshot current,
    StartWorkCommand command,
    _EventFactory events,
  ) {
    if (current.phase != TimerPhase.idle) {
      return TimerTransition.ignored(
        current,
        TimerIgnoredReason.invalidForCurrentPhase,
      );
    }
    final at = command.occurredAtUtc.toUtc();
    final next = TimerSnapshot(
      cycleId: command.cycleId,
      revision: current.revision + 1,
      phase: TimerPhase.working,
      executionStatus: ExecutionStatus.active,
      startedAtUtc: at,
      deadlineAtUtc: at.add(command.cycleConfig.workDuration),
      cycleConfig: command.cycleConfig,
    );
    return _applied(next, [
      events.create(command.cycleId, TimerEventType.workStarted, at),
    ]);
  }

  static TimerTransition _startRest(
    TimerSnapshot current,
    StartRestCommand command,
    _EventFactory events,
  ) {
    if (current.executionStatus != ExecutionStatus.active ||
        (current.phase != TimerPhase.working &&
            current.phase != TimerPhase.awaitingRest)) {
      return TimerTransition.ignored(
        current,
        TimerIgnoredReason.invalidForCurrentPhase,
      );
    }
    final at = command.occurredAtUtc.toUtc();
    final next = TimerSnapshot(
      cycleId: current.cycleId,
      revision: current.revision + 1,
      phase: TimerPhase.resting,
      executionStatus: ExecutionStatus.active,
      startedAtUtc: at,
      deadlineAtUtc: at.add(current.cycleConfig.restDuration),
      cycleConfig: current.cycleConfig,
    );
    final completedWork = _workDurationToRecord(current, at);
    return _applied(next, [
      if (completedWork > Duration.zero)
        events.create(
          current.cycleId,
          TimerEventType.workCompleted,
          at,
          duration: completedWork,
        ),
      events.create(current.cycleId, TimerEventType.restStarted, at),
    ]);
  }

  static TimerTransition _suspend(
    TimerSnapshot current,
    SuspendTimerCommand command,
    _EventFactory events,
  ) {
    if (current.phase != TimerPhase.working ||
        current.executionStatus != ExecutionStatus.active) {
      return TimerTransition.ignored(
        current,
        TimerIgnoredReason.invalidForCurrentPhase,
      );
    }
    final at = command.occurredAtUtc.toUtc();
    final remaining = current.remainingAt(at);
    if (remaining <= Duration.zero) {
      return TimerTransition.ignored(current, TimerIgnoredReason.noDeadline);
    }
    final next = TimerSnapshot(
      cycleId: current.cycleId,
      revision: current.revision + 1,
      phase: current.phase,
      executionStatus: ExecutionStatus.suspended,
      startedAtUtc: at,
      deadlineAtUtc: at.add(remaining),
      cycleConfig: current.cycleConfig,
    );
    return _applied(next, [
      events.create(
        current.cycleId,
        TimerEventType.workSuspended,
        at,
        duration: _workDurationToRecord(current, at),
      ),
    ]);
  }

  static TimerTransition _resume(
    TimerSnapshot current,
    ResumeTimerCommand command,
    _EventFactory events,
  ) {
    if (current.phase != TimerPhase.working ||
        current.executionStatus != ExecutionStatus.suspended) {
      return TimerTransition.ignored(
        current,
        TimerIgnoredReason.invalidForCurrentPhase,
      );
    }
    final at = command.occurredAtUtc.toUtc();
    final remaining = current.remainingAt(at);
    final next = TimerSnapshot(
      cycleId: current.cycleId,
      revision: current.revision + 1,
      phase: current.phase,
      executionStatus: ExecutionStatus.active,
      startedAtUtc: at,
      deadlineAtUtc: at.add(remaining),
      cycleConfig: current.cycleConfig,
    );
    return _applied(next, [
      events.create(current.cycleId, TimerEventType.workResumed, at),
    ]);
  }

  static TimerTransition _skipRest(
    TimerSnapshot current,
    SkipRestCommand command,
    _EventFactory events,
  ) {
    if (current.phase != TimerPhase.awaitingRest) {
      return TimerTransition.ignored(
        current,
        TimerIgnoredReason.invalidForCurrentPhase,
      );
    }
    final at = command.occurredAtUtc.toUtc();
    final next = _workingSnapshot(
      previous: current,
      cycleId: command.nextCycleId,
      config: command.nextCycleConfig,
      atUtc: at,
    );
    final completedWork = _workDurationToRecord(current, at);
    return _applied(next, [
      if (completedWork > Duration.zero)
        events.create(
          current.cycleId,
          TimerEventType.workCompleted,
          at,
          duration: completedWork,
        ),
      events.create(current.cycleId, TimerEventType.restSkipped, at),
      events.create(command.nextCycleId, TimerEventType.workStarted, at),
    ]);
  }

  static TimerTransition _completeRest(
    TimerSnapshot current,
    CompleteRestCommand command,
    _EventFactory events,
  ) {
    if ((current.phase != TimerPhase.resting &&
            current.phase != TimerPhase.awaitingWork) ||
        current.executionStatus != ExecutionStatus.active) {
      return TimerTransition.ignored(
        current,
        TimerIgnoredReason.invalidForCurrentPhase,
      );
    }
    final at = command.occurredAtUtc.toUtc();
    final next = _workingSnapshot(
      previous: current,
      cycleId: command.nextCycleId,
      config: command.nextCycleConfig,
      atUtc: at,
    );
    final completedRest = _restDurationToRecord(current, at);
    final restCompleted = completedRest >= current.cycleConfig.restDuration;
    return _applied(next, [
      if (restCompleted)
        events.create(
          current.cycleId,
          TimerEventType.restCompleted,
          at,
          duration: completedRest,
        )
      else
        events.create(current.cycleId, TimerEventType.restSkipped, at),
      events.create(command.nextCycleId, TimerEventType.workStarted, at),
    ]);
  }

  static TimerTransition _stop(
    TimerSnapshot current,
    StopTimerCommand command,
    _EventFactory events,
  ) {
    if (current.phase == TimerPhase.idle) {
      return TimerTransition.ignored(
        current,
        TimerIgnoredReason.invalidForCurrentPhase,
      );
    }
    final at = command.occurredAtUtc.toUtc();
    final next = TimerSnapshot.idle(
      revision: current.revision + 1,
      atUtc: at,
      cycleConfig: current.cycleConfig,
    );
    final completedWork = _workDurationToRecord(current, at);
    final completedRest = _restDurationToRecord(current, at);
    return _applied(next, [
      if (completedWork > Duration.zero)
        events.create(
          current.cycleId,
          TimerEventType.workCompleted,
          at,
          duration: completedWork,
        ),
      if (completedRest >= current.cycleConfig.restDuration)
        events.create(
          current.cycleId,
          TimerEventType.restCompleted,
          at,
          duration: completedRest,
        ),
      events.create(current.cycleId, TimerEventType.timerStopped, at),
    ]);
  }

  static TimerTransition _reconcile(
    TimerSnapshot current, {
    required TimerCommand command,
    required String nextCycleId,
    required TimerCycleConfig nextCycleConfig,
    required _EventFactory events,
  }) {
    const maxCatchUpTransitions = 10000;
    final untilUtc = command.occurredAtUtc.toUtc();
    var snapshot = current;
    var cycleIndex = 0;
    var transitionCount = 0;

    while (transitionCount < maxCatchUpTransitions) {
      final dueAt = snapshot.nextDueAtUtc;
      if (dueAt == null || dueAt.isAfter(untilUtc)) break;
      transitionCount++;

      switch (snapshot.phase) {
        case TimerPhase.idle:
          break;
        case TimerPhase.working:
          final completedWork = _workDurationToRecord(snapshot, dueAt);
          final timeoutAt = dueAt.add(snapshot.cycleConfig.reminderTimeout);
          final firstReminder = dueAt.add(
            snapshot.cycleConfig.reminderInterval,
          );
          snapshot = TimerSnapshot(
            cycleId: snapshot.cycleId,
            revision: snapshot.revision + 1,
            phase: TimerPhase.awaitingRest,
            executionStatus: snapshot.executionStatus,
            startedAtUtc: dueAt,
            deadlineAtUtc: timeoutAt,
            nextReminderAtUtc: firstReminder.isBefore(timeoutAt)
                ? firstReminder
                : null,
            cycleConfig: snapshot.cycleConfig,
          );
          events
            ..create(
              snapshot.cycleId,
              TimerEventType.workCompleted,
              dueAt,
              duration: completedWork,
            )
            ..create(snapshot.cycleId, TimerEventType.restPrompted, dueAt);
        case TimerPhase.awaitingRest:
          final timeoutAt = snapshot.deadlineAtUtc!;
          final reminderAt = snapshot.nextReminderAtUtc;
          if (reminderAt != null && reminderAt.isBefore(timeoutAt)) {
            final following = reminderAt.add(
              snapshot.cycleConfig.reminderInterval,
            );
            snapshot = TimerSnapshot(
              cycleId: snapshot.cycleId,
              revision: snapshot.revision + 1,
              phase: snapshot.phase,
              executionStatus: snapshot.executionStatus,
              startedAtUtc: snapshot.startedAtUtc,
              deadlineAtUtc: timeoutAt,
              nextReminderAtUtc: following.isBefore(timeoutAt)
                  ? following
                  : null,
              cycleConfig: snapshot.cycleConfig,
            );
            events.create(
              snapshot.cycleId,
              TimerEventType.restReminder,
              reminderAt,
            );
          } else {
            final previousCycleId = snapshot.cycleId;
            final overtimeWork = _workDurationToRecord(snapshot, timeoutAt);
            if (overtimeWork > Duration.zero) {
              events.create(
                previousCycleId,
                TimerEventType.workCompleted,
                timeoutAt,
                duration: overtimeWork,
              );
            }
            if (snapshot.cycleConfig.timeoutBehavior ==
                TimeoutBehavior.stopTimer) {
              snapshot = TimerSnapshot.idle(
                revision: snapshot.revision + 1,
                atUtc: timeoutAt,
                cycleConfig: snapshot.cycleConfig,
              );
              events.create(
                previousCycleId,
                TimerEventType.restTimedOut,
                timeoutAt,
              );
            } else {
              final generatedId = _cycleId(nextCycleId, cycleIndex++);
              snapshot = _workingSnapshot(
                previous: snapshot,
                cycleId: generatedId,
                config: nextCycleConfig,
                atUtc: timeoutAt,
              );
              events
                ..create(
                  previousCycleId,
                  TimerEventType.restTimedOut,
                  timeoutAt,
                )
                ..create(generatedId, TimerEventType.workStarted, timeoutAt);
            }
          }
        case TimerPhase.resting:
          final previousCycleId = snapshot.cycleId;
          events.create(previousCycleId, TimerEventType.workPrompted, dueAt);
          if (snapshot.cycleConfig.restCompletionBehavior ==
              RestCompletionBehavior.continueRest) {
            final timeoutAt = dueAt.add(snapshot.cycleConfig.restTimeout);
            final firstReminder = dueAt.add(
              snapshot.cycleConfig.missedWorkReminderInterval,
            );
            snapshot = TimerSnapshot(
              cycleId: snapshot.cycleId,
              revision: snapshot.revision + 1,
              phase: TimerPhase.awaitingWork,
              executionStatus: snapshot.executionStatus,
              startedAtUtc: dueAt,
              deadlineAtUtc: timeoutAt,
              nextReminderAtUtc: firstReminder.isBefore(timeoutAt)
                  ? firstReminder
                  : null,
              cycleConfig: snapshot.cycleConfig,
            );
          } else {
            final completedRestDuration = _restDurationToRecord(
              snapshot,
              dueAt,
            );
            if (completedRestDuration > Duration.zero) {
              events.create(
                previousCycleId,
                TimerEventType.restCompleted,
                dueAt,
                duration: completedRestDuration,
              );
            }
            if (snapshot.cycleConfig.restCompletionBehavior ==
                RestCompletionBehavior.stopTimer) {
              snapshot = TimerSnapshot.idle(
                revision: snapshot.revision + 1,
                atUtc: dueAt,
                cycleConfig: snapshot.cycleConfig,
              );
              events.create(
                previousCycleId,
                TimerEventType.timerStopped,
                dueAt,
              );
            } else {
              final generatedId = _cycleId(nextCycleId, cycleIndex++);
              snapshot = _workingSnapshot(
                previous: snapshot,
                cycleId: generatedId,
                config: nextCycleConfig,
                atUtc: dueAt,
              );
              events.create(generatedId, TimerEventType.workStarted, dueAt);
            }
          }
        case TimerPhase.awaitingWork:
          final timeoutAt = snapshot.deadlineAtUtc!;
          final reminderAt = snapshot.nextReminderAtUtc;
          if (reminderAt != null && reminderAt.isBefore(timeoutAt)) {
            final following = reminderAt.add(
              snapshot.cycleConfig.missedWorkReminderInterval,
            );
            snapshot = TimerSnapshot(
              cycleId: snapshot.cycleId,
              revision: snapshot.revision + 1,
              phase: snapshot.phase,
              executionStatus: snapshot.executionStatus,
              startedAtUtc: snapshot.startedAtUtc,
              deadlineAtUtc: timeoutAt,
              nextReminderAtUtc: following.isBefore(timeoutAt)
                  ? following
                  : null,
              cycleConfig: snapshot.cycleConfig,
            );
            events.create(
              snapshot.cycleId,
              TimerEventType.workReminder,
              reminderAt,
            );
          } else {
            final previousCycleId = snapshot.cycleId;
            final completedRestDuration = _restDurationToRecord(
              snapshot,
              timeoutAt,
            );
            if (completedRestDuration > Duration.zero) {
              events.create(
                previousCycleId,
                TimerEventType.restCompleted,
                timeoutAt,
                duration: completedRestDuration,
              );
            }
            if (snapshot.cycleConfig.restTimeoutBehavior ==
                TimeoutBehavior.stopTimer) {
              snapshot = TimerSnapshot.idle(
                revision: snapshot.revision + 1,
                atUtc: timeoutAt,
                cycleConfig: snapshot.cycleConfig,
              );
              events.create(
                previousCycleId,
                TimerEventType.workTimedOut,
                timeoutAt,
              );
            } else {
              final generatedId = _cycleId(nextCycleId, cycleIndex++);
              snapshot = _workingSnapshot(
                previous: snapshot,
                cycleId: generatedId,
                config: nextCycleConfig,
                atUtc: timeoutAt,
              );
              events
                ..create(
                  previousCycleId,
                  TimerEventType.workTimedOut,
                  timeoutAt,
                )
                ..create(generatedId, TimerEventType.workStarted, timeoutAt);
            }
          }
      }
    }

    final nextDueAt = snapshot.nextDueAtUtc;
    if (transitionCount == maxCatchUpTransitions &&
        nextDueAt != null &&
        !nextDueAt.isAfter(untilUtc)) {
      final abandonedCycleId = snapshot.cycleId;
      snapshot = TimerSnapshot.idle(
        revision: snapshot.revision + 1,
        atUtc: untilUtc,
        cycleConfig: snapshot.cycleConfig,
      );
      events.create(
        abandonedCycleId,
        TimerEventType.recoveryLimitReached,
        untilUtc,
      );
    }

    if (identical(snapshot, current)) {
      return TimerTransition.ignored(current, TimerIgnoredReason.noDeadline);
    }
    return _applied(snapshot, events.created);
  }

  static Duration _workDurationToRecord(TimerSnapshot snapshot, DateTime at) {
    return switch (snapshot.phase) {
      TimerPhase.working => _elapsedWorkingDuration(snapshot, at),
      TimerPhase.awaitingRest =>
        at.isAfter(snapshot.startedAtUtc)
            ? at.difference(snapshot.startedAtUtc)
            : Duration.zero,
      TimerPhase.idle ||
      TimerPhase.resting ||
      TimerPhase.awaitingWork => Duration.zero,
    };
  }

  static Duration _restDurationToRecord(TimerSnapshot snapshot, DateTime at) {
    final elapsed = at.toUtc().difference(snapshot.startedAtUtc.toUtc());
    final safeElapsed = elapsed.isNegative ? Duration.zero : elapsed;
    return switch (snapshot.phase) {
      TimerPhase.resting => safeElapsed,
      TimerPhase.awaitingWork =>
        snapshot.cycleConfig.restDuration + safeElapsed,
      TimerPhase.idle ||
      TimerPhase.working ||
      TimerPhase.awaitingRest => Duration.zero,
    };
  }

  static Duration _elapsedWorkingDuration(TimerSnapshot snapshot, DateTime at) {
    if (snapshot.executionStatus == ExecutionStatus.suspended) {
      return Duration.zero;
    }
    final deadline = snapshot.deadlineAtUtc;
    final end = deadline == null || at.isBefore(deadline) ? at : deadline;
    final elapsed = end.difference(snapshot.startedAtUtc);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  static TimerSnapshot _workingSnapshot({
    required TimerSnapshot previous,
    required String cycleId,
    required TimerCycleConfig config,
    required DateTime atUtc,
  }) {
    return TimerSnapshot(
      cycleId: cycleId,
      revision: previous.revision + 1,
      phase: TimerPhase.working,
      executionStatus: ExecutionStatus.active,
      startedAtUtc: atUtc,
      deadlineAtUtc: atUtc.add(config.workDuration),
      cycleConfig: config,
    );
  }

  static String _cycleId(String base, int index) {
    return index == 0 ? base : '$base-$index';
  }

  static TimerTransition _applied(
    TimerSnapshot snapshot,
    List<TimerEvent> events,
  ) {
    return TimerTransition(
      snapshot: snapshot,
      events: List.unmodifiable(events),
      outcome: TimerTransitionOutcome.applied,
    );
  }
}

final class _EventFactory {
  _EventFactory(this.commandId);

  final String commandId;
  final List<TimerEvent> created = [];

  TimerEvent create(
    String cycleId,
    TimerEventType type,
    DateTime occurredAtUtc, {
    Duration duration = Duration.zero,
  }) {
    final event = TimerEvent(
      eventId: '$commandId:${type.name}:${created.length}',
      cycleId: cycleId,
      type: type,
      occurredAtUtc: occurredAtUtc.toUtc(),
      duration: duration,
    );
    created.add(event);
    return event;
  }
}
