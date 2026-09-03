import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/features/timer/domain/timer_policy.dart';

final class TimerSnapshot {
  const TimerSnapshot({
    required this.cycleId,
    required this.revision,
    required this.phase,
    required this.executionStatus,
    required this.startedAtUtc,
    required this.cycleConfig,
    this.deadlineAtUtc,
    this.nextReminderAtUtc,
  });

  factory TimerSnapshot.idle({
    int revision = 0,
    DateTime? atUtc,
    TimerCycleConfig cycleConfig = TimerCycleConfig.defaults,
  }) {
    return TimerSnapshot(
      cycleId: 'idle',
      revision: revision,
      phase: TimerPhase.idle,
      executionStatus: ExecutionStatus.active,
      startedAtUtc:
          atUtc ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      cycleConfig: cycleConfig,
    );
  }

  final String cycleId;
  final int revision;
  final TimerPhase phase;
  final ExecutionStatus executionStatus;
  final DateTime startedAtUtc;
  final DateTime? deadlineAtUtc;
  final DateTime? nextReminderAtUtc;
  final TimerCycleConfig cycleConfig;

  bool get isActive => phase != TimerPhase.idle;

  Duration get phaseDuration => switch (phase) {
    TimerPhase.idle => Duration.zero,
    TimerPhase.working => cycleConfig.workDuration,
    TimerPhase.awaitingRest => cycleConfig.reminderTimeout,
    TimerPhase.resting => cycleConfig.restDuration,
  };

  Duration remainingAt(DateTime nowUtc) {
    final deadline = deadlineAtUtc;
    if (deadline == null) return Duration.zero;
    final remaining = executionStatus == ExecutionStatus.suspended
        ? deadline.difference(startedAtUtc)
        : deadline.difference(nowUtc.toUtc());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  double progressAt(DateTime nowUtc) {
    return progressForRemaining(remainingAt(nowUtc));
  }

  double progressForRemaining(Duration remaining) {
    if (phase == TimerPhase.awaitingRest) return 1;
    final total = phaseDuration.inMilliseconds;
    if (total <= 0) return 0;
    final clampedRemaining = remaining.inMilliseconds.clamp(0, total);
    return ((total - clampedRemaining) / total).clamp(0, 1);
  }

  Duration displayDurationAt(DateTime nowUtc) {
    if (_isUnboundedRest) {
      final elapsed = nowUtc.toUtc().difference(startedAtUtc.toUtc());
      return elapsed.isNegative ? Duration.zero : elapsed;
    }
    return displayDurationForRemaining(remainingAt(nowUtc));
  }

  Duration displayDurationForRemaining(Duration remaining) {
    if (phase != TimerPhase.awaitingRest) return remaining;
    final overtime = cycleConfig.reminderTimeout - remaining;
    return cycleConfig.workDuration +
        (overtime.isNegative ? Duration.zero : overtime);
  }

  bool get _isUnboundedRest =>
      phase == TimerPhase.resting &&
      deadlineAtUtc == null &&
      cycleConfig.restCompletionBehavior == RestCompletionBehavior.continueRest;
}
