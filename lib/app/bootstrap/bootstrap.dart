import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rest_eye/app/bootstrap/app_runtime.dart';
import 'package:rest_eye/app/bootstrap/app_runtime_owner.dart';
import 'package:rest_eye/app/bootstrap/app_settings_change_effects.dart';
import 'package:rest_eye/app/bootstrap/background_notification_action.dart';
import 'package:rest_eye/app/bootstrap/bootstrap_failure_app.dart';
import 'package:rest_eye/app/rest_eye_app.dart';
import 'package:rest_eye/core/clock/app_clock_provider.dart';
import 'package:rest_eye/core/clock/system_app_clock.dart';
import 'package:rest_eye/core/logging/app_logger.dart';
import 'package:rest_eye/features/settings/application/settings_dependencies.dart';
import 'package:rest_eye/features/settings/data/drift_settings_repository.dart';
import 'package:rest_eye/features/statistics/application/screen_activity_recorder.dart';
import 'package:rest_eye/features/statistics/application/statistics_dependencies.dart';
import 'package:rest_eye/features/statistics/data/drift_statistics_repository.dart';
import 'package:rest_eye/features/timer/application/notification_action_coordinator.dart';
import 'package:rest_eye/features/timer/application/notification_schedule_reconciler.dart';
import 'package:rest_eye/features/timer/application/timer_command_dispatcher.dart';
import 'package:rest_eye/features/timer/application/timer_dependencies.dart';
import 'package:rest_eye/features/timer/application/timer_runtime.dart';
import 'package:rest_eye/features/timer/application/screen_lock_pause_controller.dart';
import 'package:rest_eye/features/timer/data/drift_timer_repository.dart';
import 'package:rest_eye/infrastructure/database/app_database.dart';
import 'package:rest_eye/platform/lifecycle/flutter_lifecycle_gateway.dart';
import 'package:rest_eye/platform/notifications/local_notification_gateway.dart';
import 'package:rest_eye/platform/orientation/flutter_orientation_gateway.dart';
import 'package:rest_eye/platform/platform_capabilities_impl.dart';
import 'package:rest_eye/platform/screen_state/method_channel_screen_state_gateway.dart';
import 'package:rest_eye/platform/window/flutter_window_behavior_gateway.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppDatabase? database;
  AppRuntime? runtime;
  try {
    const logger = ConsoleAppLogger();
    final clock = SystemAppClock();
    database = AppDatabase.open();
    final settingsRepository = DriftSettingsRepository(database);
    final orientationGateway = FlutterOrientationGateway();
    final windowBehaviorGateway = FlutterWindowBehaviorGateway();
    final initialSettings = await settingsRepository.load();
    await orientationGateway.setFixedPortrait(
      enabled: initialSettings.fixedPortraitEnabled,
    );
    await windowBehaviorGateway.setMinimizeToTrayOnClose(
      enabled: initialSettings.minimizeToTrayOnClose,
    );
    final timerRepository = DriftTimerRepository(database, clock);
    final statisticsRepository = DriftStatisticsRepository(database);
    final notificationGateway = LocalNotificationGateway(
      settingsRepository,
      clock,
      onDidReceiveBackgroundNotificationResponse:
          handleBackgroundNotificationAction,
    );
    final notificationReconciler = NotificationScheduleReconciler(
      notificationGateway,
      settingsRepository,
      logger,
      clock,
    );
    final dispatcher = TimerCommandDispatcher(
      timerRepository,
      settingsRepository,
      clock,
      logger,
      notificationReconciler,
    );
    final timerRuntime = TimerRuntime(
      dispatcher,
      settingsRepository,
      clock,
      FlutterLifecycleGateway(),
      logger,
    );
    final screenStateGateway = MethodChannelScreenStateGateway(clock);
    final screenActivityRecorder = ScreenActivityRecorder(
      screenStateGateway,
      statisticsRepository,
      clock,
      logger,
    );
    final screenLockPauseController = ScreenLockPauseController(
      screenStateGateway,
      settingsRepository,
      dispatcher,
      clock,
      logger,
    );
    final notificationActionCoordinator = NotificationActionCoordinator(
      notificationGateway,
      settingsRepository,
      timerRepository,
      dispatcher,
      logger,
    );
    final settingsChangeEffects = AppSettingsChangeEffects(
      screenLockPauseController,
      notificationReconciler,
      dispatcher,
      orientationGateway,
      windowBehaviorGateway,
    );
    final platformCapabilities = detectPlatformCapabilities();

    runtime = AppRuntime(
      database: database,
      notificationGateway: notificationGateway,
      notificationActionCoordinator: notificationActionCoordinator,
      notificationReconciler: notificationReconciler,
      dispatcher: dispatcher,
      timerRuntime: timerRuntime,
      screenActivityRecorder: screenActivityRecorder,
      screenLockPauseController: screenLockPauseController,
      logger: logger,
    );
    await runtime.initialize();

    runApp(
      AppRuntimeOwner(
        runtime: runtime,
        child: ProviderScope(
          overrides: [
            appClockProvider.overrideWithValue(clock),
            settingsRepositoryProvider.overrideWithValue(settingsRepository),
            settingsChangeEffectsProvider.overrideWithValue(
              settingsChangeEffects,
            ),
            windowBehaviorGatewayProvider.overrideWithValue(
              windowBehaviorGateway,
            ),
            statisticsRepositoryProvider.overrideWithValue(
              statisticsRepository,
            ),
            screenActivityRecorderProvider.overrideWithValue(
              screenActivityRecorder,
            ),
            timerRepositoryProvider.overrideWithValue(timerRepository),
            timerCommandDispatcherProvider.overrideWithValue(dispatcher),
            timerRuntimeProvider.overrideWithValue(timerRuntime),
            notificationGatewayProvider.overrideWithValue(notificationGateway),
            notificationReconcilerProvider.overrideWithValue(
              notificationReconciler,
            ),
            screenLockPauseControllerProvider.overrideWithValue(
              screenLockPauseController,
            ),
            platformCapabilitiesProvider.overrideWithValue(
              platformCapabilities,
            ),
          ],
          child: const RestEyeApp(),
        ),
      ),
    );
  } catch (error, stackTrace) {
    const ConsoleAppLogger().error(
      'Application bootstrap failed',
      error: error,
      stackTrace: stackTrace,
    );
    if (runtime != null) {
      await runtime.dispose();
    } else {
      await database?.close();
    }
    runApp(BootstrapFailureApp(onRetry: bootstrap));
  }
}
