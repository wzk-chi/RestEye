enum TimeoutBehavior { nextCycle, stopTimer }

final class TimerCycleConfig {
  const TimerCycleConfig({
    required this.workDuration,
    required this.restDuration,
    required this.reminderInterval,
    required this.reminderTimeout,
    this.timeoutBehavior = TimeoutBehavior.nextCycle,
  });

  static const defaults = TimerCycleConfig(
    workDuration: Duration(minutes: 20),
    restDuration: Duration(seconds: 20),
    reminderInterval: Duration(minutes: 3),
    reminderTimeout: Duration(minutes: 10),
  );

  final Duration workDuration;
  final Duration restDuration;
  final Duration reminderInterval;
  final Duration reminderTimeout;
  final TimeoutBehavior timeoutBehavior;
}
