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

  /// Validates the persisted state-machine invariants at the data boundary.
  ///
  /// Keeping this check on the domain model prevents a malformed row from
  /// entering the reducer and becoming a timer that can never advance.
  void validateInvariant() {
    if (revision < 0) {
      throw const FormatException('Timer snapshot revision is negative');
    }
    if (!startedAtUtc.isUtc) {
      throw const FormatException('Timer snapshot start time is not UTC');
    }
    final deadline = deadlineAtUtc;
    final reminder = nextReminderAtUtc;
    if (phase == TimerPhase.idle) {
      if (executionStatus != ExecutionStatus.active ||
          deadline != null ||
          reminder != null) {
        throw const FormatException('Idle timer snapshot has active fields');
      }
      return;
    }
    if (executionStatus == ExecutionStatus.suspended &&
        phase != TimerPhase.working) {
      throw const FormatException('Only a working timer may be suspended');
    }
    if (deadline == null) {
      throw const FormatException('Active timer snapshot has no deadline');
    }
    if (deadline.isBefore(startedAtUtc)) {
      throw const FormatException('Timer deadline precedes its start');
    }
    if (phase == TimerPhase.working || phase == TimerPhase.resting) {
      if (reminder != null) {
        throw const FormatException('Running timer snapshot has a reminder');
      }
      return;
    }
    if (reminder != null && !reminder.isBefore(deadline)) {
      throw const FormatException('Reminder is not before timer deadline');
    }
  }

  bool get isActive => phase != TimerPhase.idle;

  Duration get phaseDuration => switch (phase) {
    TimerPhase.idle => Duration.zero,
    TimerPhase.working => cycleConfig.workDuration,
    TimerPhase.awaitingRest => cycleConfig.reminderTimeout,
    TimerPhase.resting => cycleConfig.restDuration,
    TimerPhase.awaitingWork => cycleConfig.restTimeout,
  };

  /// When the next reconciliation is due: the phase deadline, or the earlier
  /// of deadline and next reminder in the awaiting phases. Null when idle or
  /// suspended.
  DateTime? get nextDueAtUtc {
    if (executionStatus == ExecutionStatus.suspended) return null;
    return switch (phase) {
      TimerPhase.idle => null,
      TimerPhase.working || TimerPhase.resting => deadlineAtUtc,
      TimerPhase.awaitingRest ||
      TimerPhase.awaitingWork => _earlier(deadlineAtUtc, nextReminderAtUtc),
    };
  }

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
    if (phase == TimerPhase.awaitingRest || phase == TimerPhase.awaitingWork) {
      return 1;
    }
    final total = phaseDuration.inMilliseconds;
    if (total <= 0) return 0;
    final clampedRemaining = remaining.inMilliseconds.clamp(0, total);
    return ((total - clampedRemaining) / total).clamp(0, 1);
  }

  Duration displayDurationAt(DateTime nowUtc) {
    if (phase == TimerPhase.awaitingWork) {
      return displayDurationForRemaining(remainingAt(nowUtc));
    }
    if (isContinuingRestAt(nowUtc)) {
      return continuingRestDurationAt(nowUtc);
    }
    return displayDurationForRemaining(remainingAt(nowUtc));
  }

  Duration displayDurationForRemaining(Duration remaining) {
    if (phase == TimerPhase.awaitingRest) {
      final overtime = cycleConfig.reminderTimeout - remaining;
      return cycleConfig.workDuration +
          (overtime.isNegative ? Duration.zero : overtime);
    }
    if (phase == TimerPhase.awaitingWork) {
      final overtime = cycleConfig.restTimeout - remaining;
      return cycleConfig.restDuration +
          (overtime.isNegative ? Duration.zero : overtime);
    }
    return remaining;
  }

  /// The cumulative work/rest duration the UI should display as "elapsed"
  /// for the current phase at [nowUtc].
  Duration displayElapsedAt(DateTime nowUtc) {
    final remaining = remainingAt(nowUtc);
    if (phase == TimerPhase.awaitingRest || phase == TimerPhase.awaitingWork) {
      final display = displayDurationForRemaining(remaining);
      return display.isNegative ? Duration.zero : display;
    }
    if (isContinuingRestAt(nowUtc)) {
      return continuingRestDurationAt(nowUtc);
    }
    final elapsed = phaseDuration - remaining;
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  bool isContinuingRestAt(DateTime nowUtc) {
    final deadline = deadlineAtUtc;
    return phase == TimerPhase.resting &&
        cycleConfig.restCompletionBehavior ==
            RestCompletionBehavior.continueRest &&
        (deadline == null || !deadline.toUtc().isAfter(nowUtc.toUtc()));
  }

  Duration continuingRestDurationAt(DateTime nowUtc) {
    final elapsed = nowUtc.toUtc().difference(startedAtUtc.toUtc());
    final safeElapsed = elapsed.isNegative ? Duration.zero : elapsed;
    return safeElapsed;
  }

  static DateTime? _earlier(DateTime? first, DateTime? second) {
    if (first == null) return second;
    if (second == null) return first;
    return first.isBefore(second) ? first : second;
  }
}
