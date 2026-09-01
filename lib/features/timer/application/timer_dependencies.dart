import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rest_eye/features/timer/application/notification_schedule_reconciler.dart';
import 'package:rest_eye/features/timer/application/ports/notification_gateway.dart';
import 'package:rest_eye/features/timer/application/ports/platform_capabilities.dart';
import 'package:rest_eye/features/timer/application/screen_lock_pause_controller.dart';
import 'package:rest_eye/features/timer/application/timer_command_dispatcher.dart';
import 'package:rest_eye/features/timer/application/timer_runtime.dart';
import 'package:rest_eye/features/timer/domain/timer_repository.dart';

final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  throw StateError('TimerRepository must be supplied during bootstrap');
});

final timerCommandDispatcherProvider = Provider<TimerCommandDispatcher>((ref) {
  throw StateError('TimerCommandDispatcher must be supplied during bootstrap');
});

final timerRuntimeProvider = Provider<TimerRuntime>((ref) {
  throw StateError('TimerRuntime must be supplied during bootstrap');
});

final notificationGatewayProvider = Provider<NotificationGateway>((ref) {
  throw StateError('NotificationGateway must be supplied during bootstrap');
});

final notificationReconcilerProvider = Provider<NotificationScheduleReconciler>(
  (ref) {
    throw StateError(
      'NotificationScheduleReconciler must be supplied during bootstrap',
    );
  },
);

final screenLockPauseControllerProvider = Provider<ScreenLockPauseController>((
  ref,
) {
  throw StateError(
    'ScreenLockPauseController must be supplied during bootstrap',
  );
});

final platformCapabilitiesProvider = Provider<PlatformCapabilities>((ref) {
  throw StateError('PlatformCapabilities must be supplied during bootstrap');
});
