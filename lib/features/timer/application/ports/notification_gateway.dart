import 'package:rest_eye/features/timer/domain/timer_phase.dart';

enum NotificationKind { workComplete, restReminder, restComplete }

enum NotificationActionType { startRest, skipRest, startWork }

enum NotificationPermissionStatus {
  granted,
  denied,
  notDetermined,
  unavailable,
}

/// Presentation inputs the gateway needs to render a notification.
///
/// Deliberately narrow: the port must not depend on the settings domain
/// model. A `null` [localeCode] means "follow the system locale".
final class NotificationPresentationOptions {
  const NotificationPresentationOptions({required this.localeCode});

  final String? localeCode;
}

/// Whether an empty active-notification query proves that nothing is shown.
enum ActiveNotificationQueryReliability { authoritative, nonAuthoritative }

/// Optional capability for gateways whose active query has platform limits.
abstract interface class ActiveNotificationQueryCapability {
  ActiveNotificationQueryReliability get activeNotificationQueryReliability;
}

final class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.kind,
    required this.cycleId,
    required this.expectedPhase,
    required this.scheduledAtUtc,
    required this.expiresAtUtc,
    required this.vibrationEnabled,
    required this.hasRestActions,
    required this.hasStartWorkAction,
  });

  final int id;
  final NotificationKind kind;
  final String cycleId;
  final TimerPhase expectedPhase;
  final DateTime scheduledAtUtc;

  /// Last instant at which an action from this notification can affect the
  /// cycle. This also bounds recovery when a background isolate was offline.
  final DateTime expiresAtUtc;
  final bool vibrationEnabled;
  final bool hasRestActions;
  final bool hasStartWorkAction;
}

final class NotificationActionRequest {
  const NotificationActionRequest({
    required this.commandId,
    required this.notificationId,
    required this.type,
    required this.cycleId,
    required this.expectedPhase,
    required this.occurredAtUtc,
    required this.expiresAtUtc,
  });

  final String commandId;
  final int notificationId;
  final NotificationActionType type;
  final String cycleId;
  final TimerPhase expectedPhase;
  final DateTime occurredAtUtc;
  final DateTime expiresAtUtc;
}

abstract interface class NotificationGateway {
  int get maxPendingNotificationRequests;

  Future<void> initialize();

  Future<NotificationPermissionStatus> permissionStatus();

  Future<NotificationPermissionStatus> requestPermission();

  Future<Set<int>> pendingNotificationIds();

  Future<Set<int>> activeNotificationIds();

  void claimActionNotification(int notificationId);

  /// Releases a claim made by [claimActionNotification], e.g. when the action
  /// command could not be enqueued and reconciliation should take over.
  void releaseActionNotification(int notificationId);

  /// IDs currently claimed by an in-flight notification action.
  Set<int> get claimedActionNotificationIds;

  Future<void> schedule(
    ScheduledNotification notification, {
    required NotificationPresentationOptions presentation,
  });

  Future<void> cancel(int notificationId);

  Stream<NotificationActionRequest> get actions;

  Future<NotificationActionRequest?> takeLaunchAction();

  Future<void> dispose();
}
