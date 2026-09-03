import 'package:rest_eye/features/settings/domain/app_settings.dart';
import 'package:rest_eye/features/timer/domain/timer_policy.dart';

TimerCycleConfig timerCycleConfigFromSettings(AppSettings settings) {
  return TimerCycleConfig(
    workDuration: settings.workDuration,
    restDuration: settings.restDuration,
    reminderInterval: settings.reminderInterval,
    reminderTimeout: settings.reminderTimeout,
    missedWorkReminderInterval: settings.missedWorkReminderInterval,
    restTimeout: settings.restTimeout,
    timeoutBehavior: settings.timeoutBehavior,
    restTimeoutBehavior: settings.restTimeoutBehavior,
    restCompletionBehavior: settings.restCompletionBehavior,
  );
}
