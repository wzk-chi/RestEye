import 'dart:async';

import 'package:rest_eye/core/async/serial_operation_queue.dart';
import 'package:rest_eye/core/clock/app_clock.dart';
import 'package:rest_eye/core/logging/app_logger.dart';
import 'package:rest_eye/features/settings/domain/settings_repository.dart';
import 'package:rest_eye/features/timer/application/notification_delivery_tracker.dart';
import 'package:rest_eye/features/timer/application/notification_plan_projector.dart';
import 'package:rest_eye/features/timer/application/notification_settings_mapper.dart';
import 'package:rest_eye/features/timer/application/ports/notification_gateway.dart';
import 'package:rest_eye/features/timer/application/ports/platform_capabilities.dart';
import 'package:rest_eye/features/timer/domain/timer_repository.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';

final class NotificationScheduleReconciler {
  NotificationScheduleReconciler(
    this._gateway,
    this._settingsRepository,
    this._timerRepository,
    this._logger,
    this._clock,
  );

  final NotificationGateway _gateway;
  final SettingsRepository _settingsRepository;
  final TimerRepository _timerRepository;
  final AppLogger _logger;
  final AppClock _clock;
  final _availability = StreamController<CapabilityAvailability>.broadcast();
  final _planProjector = const NotificationPlanProjector();
  final _deliveryTracker = NotificationDeliveryTracker();
  final _queue = SerialOperationQueue();
  var _generation = 0;
  var _disposed = false;
  CapabilityAvailability _currentAvailability =
      CapabilityAvailability.unavailable;

  Stream<CapabilityAvailability> get availability => _availability.stream;
  CapabilityAvailability get currentAvailability => _currentAvailability;

  Future<void> reconcile(
    TimerSnapshot snapshot, {
    TimerSnapshot? previousSnapshot,
    bool forceReschedule = false,
  }) {
    if (_disposed) return Future.value();
    final generation = ++_generation;
    final operation = _queue.run(
      () => _reconcile(
        snapshot,
        previousSnapshot: previousSnapshot,
        forceReschedule: forceReschedule,
        generation: generation,
      ),
      onError: (Object error, StackTrace stackTrace) {
        _logger.warning(
          'Notification reconciliation queue failed',
          error: error,
        );
      },
    );
    return operation;
  }

  Future<void> _reconcile(
    TimerSnapshot snapshot, {
    required TimerSnapshot? previousSnapshot,
    required bool forceReschedule,
    required int generation,
  }) async {
    try {
      final settings = await _settingsRepository.load();
      if (generation != _generation) return;
      final pendingIds = await _gateway.pendingNotificationIds();
      if (generation != _generation) return;
      final activeIds = await _gateway.activeNotificationIds();
      if (generation != _generation) return;
      final durableSnapshot = await _timerRepository.loadSnapshot();
      if (generation != _generation) return;
      final inventory = NotificationDeliveryInventory(
        pendingIds: pendingIds,
        activeIds: activeIds,
        claimedIds: _gateway.claimedActionNotificationIds,
        activeQueryIsAuthoritative: _activeQueryIsAuthoritative,
      );
      _deliveryTracker.observe(inventory);
      final requestedSnapshotIsCurrent = _sameState(snapshot, durableSnapshot);
      final preferences = notificationPlanPreferences(settings);
      final plan = _planProjector.project(
        durableSnapshot,
        preferences: preferences,
        maxPendingRequests: _gateway.maxPendingNotificationRequests,
      );
      final desired = plan.items;
      final desiredById = {for (final item in desired) item.id: item};
      // Claimed (acted-on) notifications are excluded from the due protection:
      // once their command has been claimed for processing, the reconcile that
      // commits or rejects the command is responsible for cancelling them, so
      // a used reminder never lingers in the notification shade until the next
      // phase transition.
      final duePrevious = _dueNotifications(
        requestedSnapshotIsCurrent ? previousSnapshot : null,
        preferences: preferences,
      );
      final duePreviousIds = duePrevious
          .map((item) => item.id)
          .where((id) => !inventory.claimedIds.contains(id))
          .toSet();
      final obsoleteIds = inventory.platformIds
          .difference(desiredById.keys.toSet())
          .difference(duePreviousIds);
      for (final id in obsoleteIds) {
        if (generation != _generation) return;
        await _gateway.cancel(id);
        _deliveryTracker.markCancelled(id);
      }
      for (final notification in duePrevious) {
        if (generation != _generation) return;
        if (_deliveryTracker.shouldSchedule(
          notification,
          inventory: inventory,
          nowUtc: _clock.utcNow,
        )) {
          await _gateway.schedule(
            notification,
            presentation: notificationPresentationOptions(settings),
          );
          _deliveryTracker.markAccepted(notification.id);
        }
      }
      for (final notification in desiredById.values) {
        if (generation != _generation) return;
        final isPending = inventory.pendingIds.contains(notification.id);
        final isFuture = notification.scheduledAtUtc.isAfter(_clock.utcNow);
        // Rewriting a due pending or active notification can race native
        // delivery and replay its alert. Forced rewrites only apply to future
        // pending requests. Missing due notifications are only recovered when
        // the platform can authoritatively confirm that they are not active.
        if (_deliveryTracker.shouldSchedule(
              notification,
              inventory: inventory,
              nowUtc: _clock.utcNow,
            ) ||
            (forceReschedule && isPending && isFuture)) {
          await _gateway.schedule(
            notification,
            presentation: notificationPresentationOptions(settings),
          );
          _deliveryTracker.markAccepted(notification.id);
        }
      }
      if (generation != _generation) return;
      _deliveryTracker.retain({...desiredById.keys, ...duePreviousIds});
      _publishAvailability(
        plan.truncated
            ? CapabilityAvailability.degraded
            : CapabilityAvailability.available,
      );
    } catch (error) {
      _logger.warning('Notification reconciliation failed', error: error);
      _publishAvailability(CapabilityAvailability.degraded);
    }
  }

  bool _sameState(TimerSnapshot first, TimerSnapshot second) {
    return first.revision == second.revision &&
        first.cycleId == second.cycleId &&
        first.phase == second.phase &&
        first.executionStatus == second.executionStatus;
  }

  bool get _activeQueryIsAuthoritative =>
      _gateway is ActiveNotificationQueryCapability &&
      (_gateway as ActiveNotificationQueryCapability)
              .activeNotificationQueryReliability ==
          ActiveNotificationQueryReliability.authoritative;

  void _publishAvailability(CapabilityAvailability availability) {
    _currentAvailability = availability;
    if (!_availability.isClosed) _availability.add(availability);
  }

  List<ScheduledNotification> _dueNotifications(
    TimerSnapshot? snapshot, {
    required NotificationPlanPreferences preferences,
  }) {
    if (snapshot == null) return const [];
    final now = _clock.utcNow;
    return _planProjector
        .project(
          snapshot,
          preferences: preferences,
          maxPendingRequests: _gateway.maxPendingNotificationRequests,
        )
        .items
        .where((notification) {
          return !notification.scheduledAtUtc.isAfter(now);
        })
        .toList(growable: false);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _generation++;
    await _queue.idle;
    _deliveryTracker.clear();
    await _availability.close();
  }
}
