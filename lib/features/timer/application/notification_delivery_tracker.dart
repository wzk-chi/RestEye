import 'package:rest_eye/features/timer/application/ports/notification_gateway.dart';

/// A point-in-time view of notification facts reported by the platform.
final class NotificationDeliveryInventory {
  NotificationDeliveryInventory({
    required Set<int> pendingIds,
    required Set<int> activeIds,
    required Set<int> claimedIds,
    required this.activeQueryIsAuthoritative,
  }) : pendingIds = Set.unmodifiable(pendingIds),
       activeIds = Set.unmodifiable(activeIds),
       claimedIds = Set.unmodifiable(claimedIds);

  /// Scheduled requests the platform has not presented yet.
  final Set<int> pendingIds;

  /// Notifications the platform currently reports as presented.
  final Set<int> activeIds;

  /// Notifications whose action callbacks are currently being handled.
  final Set<int> claimedIds;

  /// Whether absence from [activeIds] proves that a notification is not shown.
  final bool activeQueryIsAuthoritative;

  Set<int> get platformIds => {...pendingIds, ...activeIds};

  bool contains(int id) =>
      pendingIds.contains(id) ||
      activeIds.contains(id) ||
      claimedIds.contains(id);
}

/// Tracks delivery evidence independently from the desired notification plan.
///
/// The evidence is deliberately process-local. It closes the native
/// pending-to-active hand-off race without pretending to be a persistent,
/// exactly-once delivery ledger.
final class NotificationDeliveryTracker {
  final _acceptedIds = <int>{};

  void observe(NotificationDeliveryInventory inventory) {
    _acceptedIds.addAll(inventory.pendingIds);
    _acceptedIds.addAll(inventory.activeIds);
  }

  bool shouldSchedule(
    ScheduledNotification notification, {
    required NotificationDeliveryInventory inventory,
    required DateTime nowUtc,
  }) {
    if (inventory.contains(notification.id)) return false;
    if (notification.scheduledAtUtc.isAfter(nowUtc)) return true;

    // Once the platform accepted or reported this deterministic ID, crossing
    // its deadline consumes the delivery slot. This prevents alert replay
    // while a native notification moves from pending to active.
    if (_acceptedIds.contains(notification.id)) return false;

    // A missing due notification can only be recovered when the platform can
    // prove it is neither pending nor active.
    return inventory.activeQueryIsAuthoritative;
  }

  void markAccepted(int id) => _acceptedIds.add(id);

  void markCancelled(int id) => _acceptedIds.remove(id);

  void retain(Set<int> relevantIds) => _acceptedIds.retainAll(relevantIds);

  void clear() => _acceptedIds.clear();
}
