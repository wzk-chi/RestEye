import 'dart:async';

import 'package:rest_eye/core/clock/app_clock.dart';
import 'package:rest_eye/core/logging/app_logger.dart';
import 'package:rest_eye/features/settings/domain/settings_repository.dart';
import 'package:rest_eye/features/timer/application/ports/notification_gateway.dart';
import 'package:rest_eye/features/timer/application/ports/platform_capabilities.dart';
import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/features/timer/domain/timer_policy.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';

final class NotificationPlan {
  const NotificationPlan({required this.items, required this.truncated});

  final List<ScheduledNotification> items;
  final bool truncated;
}

final class NotificationScheduleReconciler {
  NotificationScheduleReconciler(
    this._gateway,
    this._settingsRepository,
    this._logger,
    this._clock,
  );

  final NotificationGateway _gateway;
  final SettingsRepository _settingsRepository;
  final AppLogger _logger;
  final AppClock _clock;
  final _availability = StreamController<CapabilityAvailability>.broadcast();
  Future<void> _tail = Future.value();
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
    final operation = _tail.then(
      (_) => _reconcile(
        snapshot,
        previousSnapshot: previousSnapshot,
        forceReschedule: forceReschedule,
        generation: generation,
      ),
    );
    _tail = operation.then<void>(
      (_) {},
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
      final plan = derivePlan(
        snapshot,
        vibrationEnabled: settings.androidVibrationEnabled,
        workReminderEnabled: settings.workReminderEnabled,
        restReminderEnabled: settings.restReminderEnabled,
        missedRestReminderEnabled: settings.missedRestReminderEnabled,
        maxPendingRequests: _gateway.maxPendingNotificationRequests,
      );
      final desired = plan.items;
      final desiredById = {for (final item in desired) item.id: item};
      final pendingIds = await _gateway.pendingNotificationIds();
      final activeIds = await _gateway.activeNotificationIds();
      final existingIds = {...pendingIds, ...activeIds};
      final duePrevious = _dueNotifications(
        previousSnapshot,
        vibrationEnabled: settings.androidVibrationEnabled,
        workReminderEnabled: settings.workReminderEnabled,
        restReminderEnabled: settings.restReminderEnabled,
        missedRestReminderEnabled: settings.missedRestReminderEnabled,
      );
      final duePreviousIds = duePrevious.map((item) => item.id).toSet();
      final obsoleteIds = existingIds
          .difference(desiredById.keys.toSet())
          .difference(duePreviousIds);
      for (final id in obsoleteIds) {
        if (generation != _generation) return;
        await _gateway.cancel(id);
      }
      for (final notification in duePrevious) {
        if (generation != _generation) return;
        // Leave a pending alarm alone. Cancelling and immediately replacing it
        // here races Android's ScheduledNotificationReceiver at the deadline.
        // Only recover when neither the alarm nor an already-posted notice is
        // present anymore.
        if (!pendingIds.contains(notification.id) &&
            !activeIds.contains(notification.id)) {
          await _gateway.schedule(notification, settings: settings);
        }
      }
      for (final notification in desiredById.values) {
        if (generation != _generation) return;
        final isPending = pendingIds.contains(notification.id);
        final isNew = !existingIds.contains(notification.id);
        final isDuePending =
            isPending && !notification.scheduledAtUtc.isAfter(_clock.utcNow);
        if (forceReschedule || isNew || isDuePending) {
          await _gateway.schedule(notification, settings: settings);
        }
      }
      if (generation != _generation) return;
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

  void _publishAvailability(CapabilityAvailability availability) {
    _currentAvailability = availability;
    if (!_availability.isClosed) _availability.add(availability);
  }

  List<ScheduledNotification> _dueNotifications(
    TimerSnapshot? snapshot, {
    required bool vibrationEnabled,
    required bool workReminderEnabled,
    required bool restReminderEnabled,
    required bool missedRestReminderEnabled,
  }) {
    if (snapshot == null) return const [];
    final now = _clock.utcNow;
    return derivePlan(
          snapshot,
          vibrationEnabled: vibrationEnabled,
          workReminderEnabled: workReminderEnabled,
          restReminderEnabled: restReminderEnabled,
          missedRestReminderEnabled: missedRestReminderEnabled,
          maxPendingRequests: _gateway.maxPendingNotificationRequests,
        ).items
        .where((notification) {
          return !notification.scheduledAtUtc.isAfter(now);
        })
        .toList(growable: false);
  }

  NotificationPlan derivePlan(
    TimerSnapshot snapshot, {
    required bool vibrationEnabled,
    required bool workReminderEnabled,
    required bool restReminderEnabled,
    required bool missedRestReminderEnabled,
    required int maxPendingRequests,
  }) {
    if (snapshot.executionStatus == ExecutionStatus.suspended) {
      return const NotificationPlan(items: [], truncated: false);
    }
    final capacity = maxPendingRequests < 0 ? 0 : maxPendingRequests;
    final result = <ScheduledNotification>[];
    var truncated = false;
    switch (snapshot.phase) {
      case TimerPhase.idle:
        break;
      case TimerPhase.working:
        final deadline = snapshot.deadlineAtUtc;
        if (restReminderEnabled && deadline != null) {
          if (capacity > 0) {
            result.add(
              ScheduledNotification(
                id: _notificationId(snapshot.cycleId, 'workComplete', deadline),
                kind: NotificationKind.workComplete,
                cycleId: snapshot.cycleId,
                expectedPhase: TimerPhase.awaitingRest,
                expectedRevision: snapshot.revision + 1,
                scheduledAtUtc: deadline,
                vibrationEnabled: vibrationEnabled,
                hasRestActions: true,
              ),
            );
          } else {
            truncated = true;
          }
        }
      case TimerPhase.awaitingRest:
        final timeout = snapshot.deadlineAtUtc;
        var reminder = snapshot.nextReminderAtUtc;
        var occurrence = 0;
        final reminderCapacity = capacity > 0 ? capacity - 1 : 0;
        while (missedRestReminderEnabled &&
            timeout != null &&
            reminder != null &&
            reminder.isBefore(timeout)) {
          if (occurrence < reminderCapacity) {
            result.add(
              ScheduledNotification(
                id: _notificationId(snapshot.cycleId, 'restReminder', reminder),
                kind: NotificationKind.restReminder,
                cycleId: snapshot.cycleId,
                expectedPhase: TimerPhase.awaitingRest,
                expectedRevision: snapshot.revision + occurrence + 1,
                scheduledAtUtc: reminder,
                vibrationEnabled: vibrationEnabled,
                hasRestActions: true,
              ),
            );
          } else {
            truncated = true;
          }
          reminder = reminder.add(snapshot.cycleConfig.reminderInterval);
          occurrence++;
        }
      case TimerPhase.resting:
        final deadline = snapshot.deadlineAtUtc;
        if (snapshot.cycleConfig.restCompletionBehavior !=
                RestCompletionBehavior.continueRest &&
            workReminderEnabled &&
            deadline != null) {
          if (capacity > 0) {
            result.add(
              ScheduledNotification(
                id: _notificationId(snapshot.cycleId, 'restComplete', deadline),
                kind: NotificationKind.restComplete,
                cycleId: snapshot.cycleId,
                expectedPhase: TimerPhase.working,
                expectedRevision: snapshot.revision + 1,
                scheduledAtUtc: deadline,
                vibrationEnabled: vibrationEnabled,
                hasRestActions: false,
              ),
            );
          } else {
            truncated = true;
          }
        }
    }
    return NotificationPlan(
      items: List.unmodifiable(result),
      truncated: truncated,
    );
  }

  int _notificationId(String cycleId, String kind, DateTime scheduledAtUtc) {
    var hash = 0x811C9DC5;
    for (final unit
        in '$cycleId:$kind:${scheduledAtUtc.toUtc().microsecondsSinceEpoch}'
            .codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _generation++;
    await _tail;
    await _availability.close();
  }
}
