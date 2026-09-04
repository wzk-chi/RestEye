import 'package:rest_eye/features/settings/application/settings_change_effects.dart';
import 'package:rest_eye/features/settings/application/ports/orientation_gateway.dart';
import 'package:rest_eye/features/settings/application/ports/window_behavior_gateway.dart';
import 'package:rest_eye/features/settings/domain/app_settings.dart';
import 'package:rest_eye/features/timer/application/notification_schedule_reconciler.dart';
import 'package:rest_eye/features/timer/application/timer_command_dispatcher.dart';
import 'package:rest_eye/features/timer/application/screen_lock_pause_controller.dart';

final class AppSettingsChangeEffects implements SettingsChangeEffects {
  const AppSettingsChangeEffects(
    this._screenLockPauseController,
    this._notificationReconciler,
    this._dispatcher,
    this._orientationGateway,
    this._windowBehaviorGateway,
  );

  final ScreenLockPauseController _screenLockPauseController;
  final NotificationScheduleReconciler _notificationReconciler;
  final TimerCommandDispatcher _dispatcher;
  final OrientationGateway _orientationGateway;
  final WindowBehaviorGateway _windowBehaviorGateway;

  @override
  Future<void> apply(AppSettings previous, AppSettings current) async {
    // Product decision: duration changes stop the active timer. Keeping it
    // running with the old snapshot would make the displayed time disagree
    // with the new setting (or look unchanged), so the UI confirms with the
    // user before saving and the stop is applied on save.
    final timerDurationChanged =
        previous.workDuration != current.workDuration ||
        previous.restDuration != current.restDuration;
    if (timerDurationChanged) {
      await _dispatcher.stopIfActive(source: 'settings-duration-change');
    }
    if (previous.fixedPortraitEnabled != current.fixedPortraitEnabled) {
      await _orientationGateway.setFixedPortrait(
        enabled: current.fixedPortraitEnabled,
      );
    }
    if (previous.minimizeToTrayOnClose != current.minimizeToTrayOnClose) {
      await _windowBehaviorGateway.setMinimizeToTrayOnClose(
        enabled: current.minimizeToTrayOnClose,
      );
    }
    if (previous.pauseWhenLocked != current.pauseWhenLocked) {
      await _screenLockPauseController.refreshSettings();
    }
    final notificationSettingsChanged =
        previous.androidVibrationEnabled != current.androidVibrationEnabled ||
        previous.workReminderEnabled != current.workReminderEnabled ||
        previous.restReminderEnabled != current.restReminderEnabled ||
        previous.missedRestReminderEnabled !=
            current.missedRestReminderEnabled ||
        previous.missedWorkReminderEnabled !=
            current.missedWorkReminderEnabled ||
        previous.localePreference != current.localePreference;
    if (notificationSettingsChanged) {
      await _notificationReconciler.reconcile(
        _dispatcher.current,
        forceReschedule: true,
      );
    }
  }
}
