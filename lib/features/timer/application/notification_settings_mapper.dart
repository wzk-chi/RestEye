import 'package:rest_eye/features/settings/domain/app_settings.dart';
import 'package:rest_eye/features/timer/application/notification_plan_projector.dart';
import 'package:rest_eye/features/timer/application/ports/notification_gateway.dart';

NotificationPlanPreferences notificationPlanPreferences(AppSettings settings) {
  return NotificationPlanPreferences(
    vibrationEnabled: settings.androidVibrationEnabled,
    workReminderEnabled: settings.workReminderEnabled,
    restReminderEnabled: settings.restReminderEnabled,
    missedRestReminderEnabled: settings.missedRestReminderEnabled,
    missedWorkReminderEnabled: settings.missedWorkReminderEnabled,
  );
}

NotificationPresentationOptions notificationPresentationOptions(
  AppSettings settings,
) {
  return NotificationPresentationOptions(
    localeCode: settings.localePreference == AppLocalePreference.system
        ? null
        : settings.localePreference.name,
  );
}
