// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'RestEye';

  @override
  String get appFullName => 'RestEye';

  @override
  String get appTagline => 'A gentler rhythm for work and rest';

  @override
  String get navigationToday => 'Today';

  @override
  String get navigationSettings => 'Settings';

  @override
  String get navigationStatistics => 'Statistics';

  @override
  String get navigationAbout => 'About';

  @override
  String get timerPhaseIdle => 'Ready';

  @override
  String get timerPhaseWorking => 'Working';

  @override
  String get timerPhaseAwaitingRest => 'Time to rest';

  @override
  String get timerPhaseResting => 'Resting';

  @override
  String get timerPhaseSuspended => 'Paused while locked';

  @override
  String get timerIdleMessage =>
      'Start a work session and RestEye will remind you when it is time to rest.';

  @override
  String get timerWorkingMessage =>
      'Blink naturally and keep a relaxed posture.';

  @override
  String get timerAwaitingRestMessage =>
      'A timely rest helps ease eye and body fatigue; long stretches of work can let fatigue build up.';

  @override
  String get timerRestingMessage =>
      'Look away from the screen, blink slowly, and relax your shoulders.';

  @override
  String get timerSuspendedMessage => 'Work timing will resume after unlock.';

  @override
  String get timerElapsedWork => 'Worked';

  @override
  String timerElapsedWorkSemantics(String phase, String time) {
    return '$phase, worked $time';
  }

  @override
  String get timerElapsedRest => 'Rested';

  @override
  String timerElapsedRestSemantics(String phase, String time) {
    return '$phase, rested $time';
  }

  @override
  String get timerCurrentCycle => 'Current cycle';

  @override
  String timerWorkDuration(String duration) {
    return 'Work $duration';
  }

  @override
  String timerRestDuration(String duration) {
    return 'Rest $duration';
  }

  @override
  String get actionStartWork => 'Start work';

  @override
  String get actionResumeWork => 'Resume work';

  @override
  String get actionStartRest => 'Start rest';

  @override
  String get actionSkipRest => 'Skip rest';

  @override
  String get actionStopTimer => 'End timing';

  @override
  String get actionEndRest => 'End rest';

  @override
  String get actionSave => 'Save settings';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDone => 'Done';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionExit => 'Exit';

  @override
  String get actionRequestPermission => 'Enable notifications';

  @override
  String get commandFailed =>
      'The action could not be completed. Please try again.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsWorkDuration => 'Work duration';

  @override
  String get settingsRestDuration => 'Rest duration';

  @override
  String get settingsRestCompletionBehavior => 'After rest ends';

  @override
  String get settingsRestCompletionStartWork => 'Start work';

  @override
  String get settingsRestCompletionStopTimer => 'End timing';

  @override
  String get settingsRestCompletionContinueRest => 'Continue rest';

  @override
  String get settingsWorkReminder => 'Work reminder';

  @override
  String get settingsWorkReminderDescription =>
      'Remind you to start work after a rest.';

  @override
  String get settingsRestReminder => 'Rest reminder';

  @override
  String get settingsRestReminderDescription =>
      'Remind you to start resting when work ends.';

  @override
  String get settingsMissedRestReminder => 'Missed-rest repeat reminder';

  @override
  String get settingsMissedRestReminderDescription =>
      'Repeat the reminder at the set interval until you rest.';

  @override
  String get settingsReminderInterval => 'Missed-rest reminder interval';

  @override
  String get settingsReminderTimeout => 'Missed-rest timeout';

  @override
  String get settingsTimeoutBehavior => 'After a timeout';

  @override
  String get settingsTimeoutNextCycle => 'Next cycle';

  @override
  String get settingsTimeoutStopTimer => 'End timing';

  @override
  String get settingsVibration => 'Android notification vibration';

  @override
  String get settingsPauseWhenLocked => 'Pause timing when locked';

  @override
  String get settingsPauseWhenLockedDescription =>
      'Pause work timing while the device is locked and resume after unlock.';

  @override
  String get settingsSaving => 'Saving automatically…';

  @override
  String get settingsSaved => 'Saved automatically.';

  @override
  String get settingsAutoSaveFailed => 'Automatic save failed. Try again.';

  @override
  String get settingsThemeMode => 'Theme mode';

  @override
  String get settingsThemeSystem => 'Follow system';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Display language';

  @override
  String get settingsLanguageSystem => 'Follow system';

  @override
  String get settingsLanguageChinese => 'Chinese';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsFixedPortrait => 'Fixed portrait';

  @override
  String get settingsFixedPortraitDescription =>
      'Lock the app to portrait orientation.';

  @override
  String get settingsMinimizeToTrayOnClose => 'Minimize to tray when closed';

  @override
  String get settingsMinimizeToTrayOnCloseDescription =>
      'Keep running in the background after closing the window, and reopen it from the system tray.';

  @override
  String get settingsKeepInMenuBarOnClose => 'Keep in the menu bar when closed';

  @override
  String get settingsKeepInMenuBarOnCloseDescription =>
      'Keep running in the background after closing the window, and reopen it from the menu bar.';

  @override
  String get timerQuickWorkDurationTitle => 'Set work duration';

  @override
  String get timerQuickRestDurationTitle => 'Set rest duration';

  @override
  String get timerQuickDurationDescription =>
      'The new duration saves automatically and applies from the next cycle.';

  @override
  String settingsMinutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String settingsSecondsValue(int seconds) {
    return '$seconds sec';
  }

  @override
  String settingsEditValue(String setting) {
    return 'Adjust $setting';
  }

  @override
  String get validationWorkRange =>
      'Work duration must be between 1 and 180 minutes.';

  @override
  String get validationRestRange =>
      'Rest duration must be between 10 and 600 seconds.';

  @override
  String get validationReminderRange =>
      'Reminder interval must be between 1 and 30 minutes.';

  @override
  String get validationTimeoutRange =>
      'Timeout must be between 2 and 120 minutes.';

  @override
  String get validationTimeoutAfterInterval =>
      'Timeout must be longer than the reminder interval.';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get statisticsDatePickerTitle => 'Select date';

  @override
  String get statisticsRestDuration => 'Rest time';

  @override
  String get statisticsRestCount => 'Completed rests';

  @override
  String get statisticsUnavailable => 'Statistics are temporarily unavailable.';

  @override
  String get statisticsTimelineWork => 'Work';

  @override
  String get statisticsTimelineRest => 'Rest';

  @override
  String get statisticsTimelineEmpty =>
      'There are no work or rest periods to show today.';

  @override
  String get statisticsTimelineStart => '00:00';

  @override
  String get statisticsTimelineEnd => '24:00';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours hr $minutes min';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds sec';
  }

  @override
  String countTimes(int count) {
    return '$count';
  }

  @override
  String get notificationPermissionTitle => 'Notifications are off';

  @override
  String get notificationPermissionMessage =>
      'Enable system notifications so RestEye can remind you when a timer ends.';

  @override
  String get notificationDegraded =>
      'System reminders are unavailable. Timing will continue and RestEye will retry later.';

  @override
  String get notificationWorkCompleteTitle => 'Time to rest your eyes';

  @override
  String get notificationWorkCompleteBody =>
      'Rest helps ease eye and body fatigue. Avoid letting continuous work wear you down.';

  @override
  String get notificationRestReminderTitle => 'Remember to rest your eyes';

  @override
  String get notificationRestReminderBody =>
      'Rest helps ease fatigue. Start resting now or skip this reminder.';

  @override
  String get notificationRestCompleteTitle => 'Rest complete';

  @override
  String get notificationRestCompleteBody => 'Your rest time is up.';

  @override
  String get notificationActionStartRest => 'Start rest';

  @override
  String get notificationActionSkipRest => 'Skip';

  @override
  String get trayOpenApp => 'Open';

  @override
  String get trayExitApp => 'Exit';

  @override
  String get notificationChannelName => 'Eye-rest reminders';

  @override
  String get notificationChannelDescription =>
      'Work completion, rest reminders, and rest completion';

  @override
  String get aboutTitle => 'About RestEye';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutGuidanceTitle => 'The 20-20-20 rule';

  @override
  String get aboutGuidanceBody =>
      'Every 20 minutes, look about 6 metres away for at least 20 seconds.';

  @override
  String get aboutPrivacyTitle => 'Local and private';

  @override
  String get aboutPrivacyBody =>
      'RestEye has no account or cloud sync. Settings and statistics stay on this device by default.';

  @override
  String get aboutRepositoryTitle => 'GitHub repository';

  @override
  String get aboutRepositoryBody => 'github.com/wzk-chi/RestEye';

  @override
  String get aboutRepositoryOpenFailed =>
      'Unable to open the GitHub repository.';

  @override
  String get bootstrapFailureTitle => 'RestEye could not start';

  @override
  String get bootstrapFailureMessage =>
      'Your local data was not deleted. Retry, or exit and reopen the app.';

  @override
  String accessibilityTimerProgress(int percent) {
    return 'Cycle progress $percent%';
  }

  @override
  String accessibilityOpenSection(String section) {
    return 'Open $section';
  }
}
