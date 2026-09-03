enum TimerEventType {
  workStarted,
  workCompleted,
  workSuspended,
  workResumed,
  restPrompted,
  restReminder,
  restStarted,
  restCompleted,
  restSkipped,
  restTimedOut,
  workPrompted,
  workReminder,
  workTimedOut,
  timerStopped,
  recoveryLimitReached,
}

final class TimerEvent {
  const TimerEvent({
    required this.eventId,
    required this.cycleId,
    required this.type,
    required this.occurredAtUtc,
    this.duration = Duration.zero,
  });

  final String eventId;
  final String cycleId;
  final TimerEventType type;
  final DateTime occurredAtUtc;
  final Duration duration;
}
