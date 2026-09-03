import 'package:rest_eye/core/error/app_failure.dart';
import 'package:rest_eye/features/timer/domain/timer_policy.dart';

enum AppLocalePreference { system, zh, en }

enum AppThemePreference { system, light, dark }

final class AppSettings {
  const AppSettings({
    required this.workDuration,
    required this.restDuration,
    required this.reminderInterval,
    required this.reminderTimeout,
    required this.androidVibrationEnabled,
    required this.workReminderEnabled,
    required this.restReminderEnabled,
    required this.missedRestReminderEnabled,
    required this.localePreference,
    required this.themePreference,
    this.pauseWhenLocked = false,
    this.fixedPortraitEnabled = true,
    this.minimizeToTrayOnClose = true,
    this.timeoutBehavior = TimeoutBehavior.nextCycle,
    this.restCompletionBehavior = RestCompletionBehavior.startWork,
  });

  static const defaults = AppSettings(
    workDuration: Duration(minutes: 20),
    restDuration: Duration(seconds: 20),
    reminderInterval: Duration(minutes: 3),
    reminderTimeout: Duration(minutes: 10),
    androidVibrationEnabled: true,
    workReminderEnabled: true,
    restReminderEnabled: true,
    missedRestReminderEnabled: true,
    localePreference: AppLocalePreference.system,
    themePreference: AppThemePreference.system,
  );

  static const minWorkDuration = Duration(minutes: 1);
  static const maxWorkDuration = Duration(minutes: 180);
  static const minRestDuration = Duration(seconds: 10);
  static const maxRestDuration = Duration(seconds: 600);
  static const minReminderInterval = Duration(minutes: 1);
  static const maxReminderInterval = Duration(minutes: 30);
  static const minReminderTimeout = Duration(minutes: 2);
  static const maxReminderTimeout = Duration(minutes: 120);

  final Duration workDuration;
  final Duration restDuration;
  final Duration reminderInterval;
  final Duration reminderTimeout;
  final bool androidVibrationEnabled;
  final bool workReminderEnabled;
  final bool restReminderEnabled;
  final bool missedRestReminderEnabled;
  final AppLocalePreference localePreference;
  final AppThemePreference themePreference;
  final bool pauseWhenLocked;
  final bool fixedPortraitEnabled;
  final bool minimizeToTrayOnClose;
  final TimeoutBehavior timeoutBehavior;
  final RestCompletionBehavior restCompletionBehavior;

  ValidationFailureCode? validate() {
    if (workDuration < minWorkDuration || workDuration > maxWorkDuration) {
      return ValidationFailureCode.workDurationOutOfRange;
    }
    if (restDuration < minRestDuration || restDuration > maxRestDuration) {
      return ValidationFailureCode.restDurationOutOfRange;
    }
    if (reminderInterval < minReminderInterval ||
        reminderInterval > maxReminderInterval) {
      return ValidationFailureCode.reminderIntervalOutOfRange;
    }
    if (reminderTimeout < minReminderTimeout ||
        reminderTimeout > maxReminderTimeout) {
      return ValidationFailureCode.reminderTimeoutOutOfRange;
    }
    if (reminderTimeout <= reminderInterval) {
      return ValidationFailureCode.reminderTimeoutNotAfterInterval;
    }
    return null;
  }

  AppSettings copyWith({
    Duration? workDuration,
    Duration? restDuration,
    Duration? reminderInterval,
    Duration? reminderTimeout,
    bool? androidVibrationEnabled,
    bool? workReminderEnabled,
    bool? restReminderEnabled,
    bool? missedRestReminderEnabled,
    AppLocalePreference? localePreference,
    AppThemePreference? themePreference,
    bool? pauseWhenLocked,
    bool? fixedPortraitEnabled,
    bool? minimizeToTrayOnClose,
    TimeoutBehavior? timeoutBehavior,
    RestCompletionBehavior? restCompletionBehavior,
  }) {
    return AppSettings(
      workDuration: workDuration ?? this.workDuration,
      restDuration: restDuration ?? this.restDuration,
      reminderInterval: reminderInterval ?? this.reminderInterval,
      reminderTimeout: reminderTimeout ?? this.reminderTimeout,
      androidVibrationEnabled:
          androidVibrationEnabled ?? this.androidVibrationEnabled,
      workReminderEnabled: workReminderEnabled ?? this.workReminderEnabled,
      restReminderEnabled: restReminderEnabled ?? this.restReminderEnabled,
      missedRestReminderEnabled:
          missedRestReminderEnabled ?? this.missedRestReminderEnabled,
      localePreference: localePreference ?? this.localePreference,
      themePreference: themePreference ?? this.themePreference,
      pauseWhenLocked: pauseWhenLocked ?? this.pauseWhenLocked,
      fixedPortraitEnabled: fixedPortraitEnabled ?? this.fixedPortraitEnabled,
      minimizeToTrayOnClose:
          minimizeToTrayOnClose ?? this.minimizeToTrayOnClose,
      timeoutBehavior: timeoutBehavior ?? this.timeoutBehavior,
      restCompletionBehavior:
          restCompletionBehavior ?? this.restCompletionBehavior,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          workDuration == other.workDuration &&
          restDuration == other.restDuration &&
          reminderInterval == other.reminderInterval &&
          reminderTimeout == other.reminderTimeout &&
          androidVibrationEnabled == other.androidVibrationEnabled &&
          workReminderEnabled == other.workReminderEnabled &&
          restReminderEnabled == other.restReminderEnabled &&
          missedRestReminderEnabled == other.missedRestReminderEnabled &&
          localePreference == other.localePreference &&
          themePreference == other.themePreference &&
          pauseWhenLocked == other.pauseWhenLocked &&
          fixedPortraitEnabled == other.fixedPortraitEnabled &&
          minimizeToTrayOnClose == other.minimizeToTrayOnClose &&
          timeoutBehavior == other.timeoutBehavior &&
          restCompletionBehavior == other.restCompletionBehavior;

  @override
  int get hashCode => Object.hash(
    workDuration,
    restDuration,
    reminderInterval,
    reminderTimeout,
    androidVibrationEnabled,
    workReminderEnabled,
    restReminderEnabled,
    missedRestReminderEnabled,
    localePreference,
    themePreference,
    pauseWhenLocked,
    fixedPortraitEnabled,
    minimizeToTrayOnClose,
    timeoutBehavior,
    restCompletionBehavior,
  );
}
