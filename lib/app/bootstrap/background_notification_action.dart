import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rest_eye/core/clock/system_app_clock.dart';
import 'package:rest_eye/core/logging/app_logger.dart';
import 'package:rest_eye/features/settings/data/drift_settings_repository.dart';
import 'package:rest_eye/features/timer/application/notification_action_coordinator.dart';
import 'package:rest_eye/features/timer/application/notification_schedule_reconciler.dart';
import 'package:rest_eye/features/timer/application/timer_command_dispatcher.dart';
import 'package:rest_eye/features/timer/data/drift_timer_repository.dart';
import 'package:rest_eye/infrastructure/database/app_database.dart';
import 'package:rest_eye/platform/notifications/local_notification_gateway.dart';

@pragma('vm:entry-point')
void handleBackgroundNotificationAction(NotificationResponse response) {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(_handleBackgroundNotificationAction(response));
}

Future<void> _handleBackgroundNotificationAction(
  NotificationResponse response,
) async {
  const logger = ConsoleAppLogger();
  final clock = SystemAppClock();
  final action = parseLocalNotificationActionResponse(response, clock);
  if (action == null) return;

  final database = AppDatabase.open();
  final settingsRepository = DriftSettingsRepository(database);
  final timerRepository = DriftTimerRepository(database, clock);
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
  final coordinator = NotificationActionCoordinator(
    notificationGateway,
    settingsRepository,
    timerRepository,
    dispatcher,
    logger,
  );

  try {
    await notificationGateway.initialize();
    await dispatcher.initialize();
    await coordinator.handleAction(action);
  } catch (error, stackTrace) {
    logger.error(
      'Background notification action failed',
      error: error,
      stackTrace: stackTrace,
    );
  } finally {
    await _disposeStep(
      logger,
      'notification action coordinator',
      coordinator.dispose,
    );
    await _disposeStep(logger, 'timer dispatcher', dispatcher.dispose);
    await _disposeStep(
      logger,
      'notification reconciler',
      notificationReconciler.dispose,
    );
    await _disposeStep(
      logger,
      'notification gateway',
      notificationGateway.dispose,
    );
    await _disposeStep(logger, 'database', database.close);
  }
}

Future<void> _disposeStep(
  AppLogger logger,
  String component,
  FutureOr<void> Function() action,
) async {
  try {
    await action();
  } catch (error, stackTrace) {
    logger.error(
      'Background notification cleanup failed for $component',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
