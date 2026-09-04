import 'package:rest_eye/core/build/app_build.dart';

enum TimeoutBehavior { nextCycle, stopTimer }

enum RestCompletionBehavior { startWork, stopTimer, continueRest }

final class TimerCycleConfig {
  const TimerCycleConfig({
    required this.workDuration,
    required this.restDuration,
    required this.reminderInterval,
    required this.reminderTimeout,
    required this.missedWorkReminderInterval,
    required this.restTimeout,
    this.timeoutBehavior = TimeoutBehavior.nextCycle,
    this.restTimeoutBehavior = TimeoutBehavior.nextCycle,
    this.restCompletionBehavior = RestCompletionBehavior.startWork,
  });

  static const defaults = TimerCycleConfig(
    workDuration: AppBuild.defaultWorkDuration,
    restDuration: AppBuild.defaultRestDuration,
    reminderInterval: Duration(minutes: 3),
    reminderTimeout: Duration(minutes: 10),
    missedWorkReminderInterval: Duration(minutes: 3),
    restTimeout: Duration(minutes: 10),
  );

  final Duration workDuration;
  final Duration restDuration;
  final Duration reminderInterval;
  final Duration reminderTimeout;
  final Duration missedWorkReminderInterval;
  final Duration restTimeout;
  final TimeoutBehavior timeoutBehavior;
  final TimeoutBehavior restTimeoutBehavior;
  final RestCompletionBehavior restCompletionBehavior;
}
