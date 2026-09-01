import 'dart:async';

import 'package:rest_eye/core/logging/app_logger.dart';
import 'package:rest_eye/features/statistics/application/screen_activity_recorder.dart';
import 'package:rest_eye/features/timer/application/notification_action_coordinator.dart';
import 'package:rest_eye/features/timer/application/notification_schedule_reconciler.dart';
import 'package:rest_eye/features/timer/application/ports/notification_gateway.dart';
import 'package:rest_eye/features/timer/application/screen_lock_pause_controller.dart';
import 'package:rest_eye/features/timer/application/timer_command_dispatcher.dart';
import 'package:rest_eye/features/timer/application/timer_runtime.dart';
import 'package:rest_eye/infrastructure/database/app_database.dart';

final class AppRuntime {
  AppRuntime({
    required this.database,
    required this.notificationGateway,
    required this.notificationActionCoordinator,
    required this.notificationReconciler,
    required this.dispatcher,
    required this.timerRuntime,
    required this.screenActivityRecorder,
    required this.screenLockPauseController,
    required this.logger,
  });

  final AppDatabase database;
  final NotificationGateway notificationGateway;
  final NotificationActionCoordinator notificationActionCoordinator;
  final NotificationScheduleReconciler notificationReconciler;
  final TimerCommandDispatcher dispatcher;
  final TimerRuntime timerRuntime;
  final ScreenActivityRecorder screenActivityRecorder;
  final ScreenLockPauseController screenLockPauseController;
  final AppLogger logger;
  var _initialized = false;
  var _disposed = false;

  Future<void> initialize() async {
    if (_initialized || _disposed) return;
    try {
      await notificationGateway.initialize();
      await dispatcher.initialize();
      await dispatcher.stopIfActive(source: 'startup');
      await notificationActionCoordinator.initialize();
      await dispatcher.recover();
      timerRuntime.start();
      await screenActivityRecorder.start();
      await screenLockPauseController.start();
      _initialized = true;
    } catch (_) {
      await dispose();
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _disposeStep(
      'active timer',
      () => dispatcher.stopIfActive(source: 'shutdown'),
    );
    await _disposeStep(
      'notification action coordinator',
      notificationActionCoordinator.dispose,
    );
    await _disposeStep('screen lock pause', screenLockPauseController.dispose);
    await _disposeStep(
      'screen activity recorder',
      screenActivityRecorder.dispose,
    );
    await _disposeStep('timer runtime', timerRuntime.dispose);
    await _disposeStep('timer dispatcher', dispatcher.dispose);
    await _disposeStep(
      'notification reconciler',
      notificationReconciler.dispose,
    );
    await _disposeStep('notification gateway', notificationGateway.dispose);
    await _disposeStep('database', database.close);
  }

  Future<void> _disposeStep(
    String component,
    FutureOr<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error, stackTrace) {
      logger.error(
        'Runtime cleanup failed for $component',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
