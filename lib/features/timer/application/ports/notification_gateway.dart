import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/features/settings/domain/app_settings.dart';

enum NotificationKind { workComplete, restReminder, restComplete }

enum NotificationActionType { startRest, skipRest, startWork }

enum NotificationPermissionStatus {
  granted,
  denied,
  notDetermined,
  unavailable,
}

final class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.kind,
    required this.cycleId,
    required this.expectedPhase,
    required this.expectedRevision,
    required this.scheduledAtUtc,
    required this.vibrationEnabled,
    required this.hasRestActions,
    required this.hasStartWorkAction,
  });

  final int id;
  final NotificationKind kind;
  final String cycleId;
  final TimerPhase expectedPhase;
  final int expectedRevision;
  final DateTime scheduledAtUtc;
  final bool vibrationEnabled;
  final bool hasRestActions;
  final bool hasStartWorkAction;
}

final class NotificationActionRequest {
  const NotificationActionRequest({
    required this.commandId,
    required this.type,
    required this.cycleId,
    required this.expectedPhase,
    required this.expectedRevision,
    required this.occurredAtUtc,
  });

  final String commandId;
  final NotificationActionType type;
  final String cycleId;
  final TimerPhase expectedPhase;
  final int expectedRevision;
  final DateTime occurredAtUtc;
}

abstract interface class NotificationGateway {
  int get maxPendingNotificationRequests;

  Future<void> initialize();

  Future<NotificationPermissionStatus> permissionStatus();

  Future<NotificationPermissionStatus> requestPermission();

  Future<Set<int>> pendingNotificationIds();

  Future<Set<int>> activeNotificationIds();

  Future<void> schedule(
    ScheduledNotification notification, {
    required AppSettings settings,
  });

  Future<void> cancel(int notificationId);

  Stream<NotificationActionRequest> get actions;

  Future<NotificationActionRequest?> takeLaunchAction();

  Future<void> dispose();
}
