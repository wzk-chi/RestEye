import 'package:rest_eye/core/config/app_build.dart';
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
    required this.missedWorkReminderInterval,
    required this.restTimeout,
    required this.androidVibrationEnabled,
    required this.workReminderEnabled,
    required this.restReminderEnabled,
    required this.missedRestReminderEnabled,
    required this.missedWorkReminderEnabled,
    required this.localePreference,
    required this.themePreference,
    this.pauseWhenLocked = false,
    this.fixedPortraitEnabled = true,
    this.minimizeToTrayOnClose = true,
    this.timeoutBehavior = TimeoutBehavior.nextCycle,
    this.restTimeoutBehavior = TimeoutBehavior.nextCycle,
    this.restCompletionBehavior = RestCompletionBehavior.startWork,
  });

  static const defaults = AppSettings(
    workDuration: AppBuild.defaultWorkDuration,
    restDuration: AppBuild.defaultRestDuration,
    reminderInterval: Duration(minutes: 3),
    reminderTimeout: Duration(minutes: 10),
    missedWorkReminderInterval: Duration(minutes: 3),
    restTimeout: Duration(minutes: 10),
    androidVibrationEnabled: true,
    workReminderEnabled: true,
    restReminderEnabled: true,
    missedRestReminderEnabled: true,
    missedWorkReminderEnabled: true,
    localePreference: AppLocalePreference.system,
    themePreference: AppThemePreference.system,
  );

  static const minWorkDuration = AppBuild.minWorkDuration;
  static const maxWorkDuration = Duration(minutes: 180);
  static const minRestDuration = AppBuild.minRestDuration;
  static const maxRestDuration = Duration(seconds: 600);
  static const minReminderInterval = Duration(minutes: 1);
  static const maxReminderInterval = Duration(minutes: 30);
  static const minReminderTimeout = Duration(minutes: 2);
  static const maxReminderTimeout = Duration(minutes: 120);

  final Duration workDuration;
  final Duration restDuration;
  final Duration reminderInterval;
  final Duration reminderTimeout;
  final Duration missedWorkReminderInterval;
  final Duration restTimeout;
  final bool androidVibrationEnabled;
  final bool workReminderEnabled;
  final bool restReminderEnabled;
  final bool missedRestReminderEnabled;
  final bool missedWorkReminderEnabled;
  final AppLocalePreference localePreference;
  final AppThemePreference themePreference;
  final bool pauseWhenLocked;
  final bool fixedPortraitEnabled;
  final bool minimizeToTrayOnClose;
  final TimeoutBehavior timeoutBehavior;
  final TimeoutBehavior restTimeoutBehavior;
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
    if (missedWorkReminderInterval < minReminderInterval ||
        missedWorkReminderInterval > maxReminderInterval) {
      return ValidationFailureCode.missedWorkReminderIntervalOutOfRange;
    }
    if (restTimeout < minReminderTimeout || restTimeout > maxReminderTimeout) {
      return ValidationFailureCode.restTimeoutOutOfRange;
    }
    if (restTimeout <= missedWorkReminderInterval) {
      return ValidationFailureCode.restTimeoutNotAfterInterval;
    }
    return null;
  }

  AppSettings copyWith({
    Duration? workDuration,
    Duration? restDuration,
    Duration? reminderInterval,
    Duration? reminderTimeout,
    Duration? missedWorkReminderInterval,
    Duration? restTimeout,
    bool? androidVibrationEnabled,
    bool? workReminderEnabled,
    bool? restReminderEnabled,
    bool? missedRestReminderEnabled,
    bool? missedWorkReminderEnabled,
    AppLocalePreference? localePreference,
    AppThemePreference? themePreference,
    bool? pauseWhenLocked,
    bool? fixedPortraitEnabled,
    bool? minimizeToTrayOnClose,
    TimeoutBehavior? timeoutBehavior,
    TimeoutBehavior? restTimeoutBehavior,
    RestCompletionBehavior? restCompletionBehavior,
  }) {
    return AppSettings(
      workDuration: workDuration ?? this.workDuration,
      restDuration: restDuration ?? this.restDuration,
      reminderInterval: reminderInterval ?? this.reminderInterval,
      reminderTimeout: reminderTimeout ?? this.reminderTimeout,
      missedWorkReminderInterval:
          missedWorkReminderInterval ?? this.missedWorkReminderInterval,
      restTimeout: restTimeout ?? this.restTimeout,
      androidVibrationEnabled:
          androidVibrationEnabled ?? this.androidVibrationEnabled,
      workReminderEnabled: workReminderEnabled ?? this.workReminderEnabled,
      restReminderEnabled: restReminderEnabled ?? this.restReminderEnabled,
      missedRestReminderEnabled:
          missedRestReminderEnabled ?? this.missedRestReminderEnabled,
      missedWorkReminderEnabled:
          missedWorkReminderEnabled ?? this.missedWorkReminderEnabled,
      localePreference: localePreference ?? this.localePreference,
      themePreference: themePreference ?? this.themePreference,
      pauseWhenLocked: pauseWhenLocked ?? this.pauseWhenLocked,
      fixedPortraitEnabled: fixedPortraitEnabled ?? this.fixedPortraitEnabled,
      minimizeToTrayOnClose:
          minimizeToTrayOnClose ?? this.minimizeToTrayOnClose,
      timeoutBehavior: timeoutBehavior ?? this.timeoutBehavior,
      restTimeoutBehavior: restTimeoutBehavior ?? this.restTimeoutBehavior,
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
          missedWorkReminderInterval == other.missedWorkReminderInterval &&
          restTimeout == other.restTimeout &&
          androidVibrationEnabled == other.androidVibrationEnabled &&
          workReminderEnabled == other.workReminderEnabled &&
          restReminderEnabled == other.restReminderEnabled &&
          missedRestReminderEnabled == other.missedRestReminderEnabled &&
          missedWorkReminderEnabled == other.missedWorkReminderEnabled &&
          localePreference == other.localePreference &&
          themePreference == other.themePreference &&
          pauseWhenLocked == other.pauseWhenLocked &&
          fixedPortraitEnabled == other.fixedPortraitEnabled &&
          minimizeToTrayOnClose == other.minimizeToTrayOnClose &&
          timeoutBehavior == other.timeoutBehavior &&
          restTimeoutBehavior == other.restTimeoutBehavior &&
          restCompletionBehavior == other.restCompletionBehavior;

  @override
  int get hashCode => Object.hash(
    workDuration,
    restDuration,
    reminderInterval,
    reminderTimeout,
    missedWorkReminderInterval,
    restTimeout,
    androidVibrationEnabled,
    workReminderEnabled,
    restReminderEnabled,
    missedRestReminderEnabled,
    missedWorkReminderEnabled,
    localePreference,
    themePreference,
    pauseWhenLocked,
    fixedPortraitEnabled,
    minimizeToTrayOnClose,
    timeoutBehavior,
    restTimeoutBehavior,
    restCompletionBehavior,
  );
}
