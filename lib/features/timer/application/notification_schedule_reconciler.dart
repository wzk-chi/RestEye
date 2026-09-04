import 'dart:async';

import 'package:rest_eye/core/async/serial_operation_queue.dart';
import 'package:rest_eye/core/clock/app_clock.dart';
import 'package:rest_eye/core/logging/app_logger.dart';
import 'package:rest_eye/features/settings/domain/app_settings.dart';
import 'package:rest_eye/features/settings/domain/settings_repository.dart';
import 'package:rest_eye/features/timer/application/ports/notification_gateway.dart';
import 'package:rest_eye/features/timer/application/ports/platform_capabilities.dart';
import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/features/timer/domain/timer_policy.dart';
import 'package:rest_eye/features/timer/domain/timer_repository.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';

final class NotificationPlan {
  const NotificationPlan({required this.items, required this.truncated});

  final List<ScheduledNotification> items;
  final bool truncated;
}

NotificationPresentationOptions notificationPresentationOptions(
  AppSettings settings,
) {
  return NotificationPresentationOptions(
    localeCode: settings.localePreference == AppLocalePreference.system
        ? null
        : settings.localePreference.name,
  );
}

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
  final _deliveryFencedIds = <int>{};
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
      final activeIds = await _gateway.activeNotificationIds();
      final activeQueryIsAuthoritative =
          _gateway is ActiveNotificationQueryCapability &&
          (_gateway as ActiveNotificationQueryCapability)
                  .activeNotificationQueryReliability ==
              ActiveNotificationQueryReliability.authoritative;
      _deliveryFencedIds.addAll(pendingIds);
      _deliveryFencedIds.addAll(activeIds);
      final durableSnapshot = await _timerRepository.loadSnapshot();
      if (generation != _generation) return;
      final requestedSnapshotIsCurrent = _sameState(snapshot, durableSnapshot);
      final plan = derivePlan(
        durableSnapshot,
        vibrationEnabled: settings.androidVibrationEnabled,
        workReminderEnabled: settings.workReminderEnabled,
        restReminderEnabled: settings.restReminderEnabled,
        missedRestReminderEnabled: settings.missedRestReminderEnabled,
        missedWorkReminderEnabled: settings.missedWorkReminderEnabled,
        maxPendingRequests: _gateway.maxPendingNotificationRequests,
      );
      final desired = plan.items;
      final desiredById = {for (final item in desired) item.id: item};
      final existingIds = {...pendingIds, ...activeIds};
      // Claimed (acted-on) notifications are excluded from the due protection:
      // once their command has been claimed for processing, the reconcile that
      // commits or rejects the command is responsible for cancelling them, so
      // a used reminder never lingers in the notification shade until the next
      // phase transition.
      final claimedIds = _gateway.claimedActionNotificationIds;
      final duePrevious = _dueNotifications(
        requestedSnapshotIsCurrent ? previousSnapshot : null,
        vibrationEnabled: settings.androidVibrationEnabled,
        workReminderEnabled: settings.workReminderEnabled,
        restReminderEnabled: settings.restReminderEnabled,
        missedRestReminderEnabled: settings.missedRestReminderEnabled,
        missedWorkReminderEnabled: settings.missedWorkReminderEnabled,
      );
      final duePreviousIds = duePrevious
          .map((item) => item.id)
          .where((id) => !claimedIds.contains(id))
          .toSet();
      final obsoleteIds = existingIds
          .difference(desiredById.keys.toSet())
          .difference(duePreviousIds);
      for (final id in obsoleteIds) {
        if (generation != _generation) return;
        await _gateway.cancel(id);
        _deliveryFencedIds.remove(id);
      }
      for (final notification in duePrevious) {
        if (generation != _generation) return;
        if (_shouldScheduleMissing(
          notification,
          pendingIds: pendingIds,
          activeIds: activeIds,
          activeQueryIsAuthoritative: activeQueryIsAuthoritative,
        )) {
          await _gateway.schedule(
            notification,
            presentation: notificationPresentationOptions(settings),
          );
          _deliveryFencedIds.add(notification.id);
        }
      }
      for (final notification in desiredById.values) {
        if (generation != _generation) return;
        final isPending = pendingIds.contains(notification.id);
        final isFuture = notification.scheduledAtUtc.isAfter(_clock.utcNow);
        // Rewriting a due pending or active notification can race native
        // delivery and replay its alert. Forced rewrites only apply to future
        // pending requests. Missing due notifications are only recovered when
        // the platform can authoritatively confirm that they are not active.
        if (_shouldScheduleMissing(
              notification,
              pendingIds: pendingIds,
              activeIds: activeIds,
              activeQueryIsAuthoritative: activeQueryIsAuthoritative,
            ) ||
            (forceReschedule && isPending && isFuture)) {
          await _gateway.schedule(
            notification,
            presentation: notificationPresentationOptions(settings),
          );
          _deliveryFencedIds.add(notification.id);
        }
      }
      if (generation != _generation) return;
      _deliveryFencedIds.retainAll({...desiredById.keys, ...duePreviousIds});
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

  bool _shouldScheduleMissing(
    ScheduledNotification notification, {
    required Set<int> pendingIds,
    required Set<int> activeIds,
    required bool activeQueryIsAuthoritative,
  }) {
    if (pendingIds.contains(notification.id) ||
        activeIds.contains(notification.id)) {
      return false;
    }
    if (notification.scheduledAtUtc.isAfter(_clock.utcNow)) return true;

    // Once a platform has accepted or reported a deterministic notification
    // ID, crossing its deadline consumes that delivery slot. This closes the
    // pending-to-active hand-off race without persisting a heartbeat or ledger.
    if (_deliveryFencedIds.contains(notification.id)) return false;

    // An empty active list is proof of absence only on platforms that expose
    // an authoritative query. Unpackaged Windows apps return an empty list for
    // every query, including while their toast is visibly on screen.
    return activeQueryIsAuthoritative;
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
    required bool missedWorkReminderEnabled,
  }) {
    if (snapshot == null) return const [];
    final now = _clock.utcNow;
    return derivePlan(
          snapshot,
          vibrationEnabled: vibrationEnabled,
          workReminderEnabled: workReminderEnabled,
          restReminderEnabled: restReminderEnabled,
          missedRestReminderEnabled: missedRestReminderEnabled,
          missedWorkReminderEnabled: missedWorkReminderEnabled,
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
    required bool missedWorkReminderEnabled,
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
                expiresAtUtc: deadline.add(
                  snapshot.cycleConfig.reminderTimeout,
                ),
                vibrationEnabled: vibrationEnabled,
                hasRestActions: true,
                hasStartWorkAction: false,
              ),
            );
          } else {
            truncated = true;
          }
        }
        if (deadline != null) {
          // Pre-schedule the finite waiting window as well. The native alarm
          // can still display missed-rest reminders while the Dart isolate is
          // backgrounded or reclaimed; the next foreground reconciliation
          // will commit the corresponding phase transitions.
          final timeout = deadline.add(snapshot.cycleConfig.reminderTimeout);
          var reminder = deadline.add(snapshot.cycleConfig.reminderInterval);
          var occurrence = 0;
          while (missedRestReminderEnabled && reminder.isBefore(timeout)) {
            if (occurrence + 1 < capacity) {
              result.add(
                ScheduledNotification(
                  id: _notificationId(
                    snapshot.cycleId,
                    'restReminder',
                    reminder,
                  ),
                  kind: NotificationKind.restReminder,
                  cycleId: snapshot.cycleId,
                  expectedPhase: TimerPhase.awaitingRest,
                  expectedRevision: snapshot.revision + occurrence + 2,
                  scheduledAtUtc: reminder,
                  expiresAtUtc: timeout,
                  vibrationEnabled: vibrationEnabled,
                  hasRestActions: true,
                  hasStartWorkAction: false,
                ),
              );
            } else {
              truncated = true;
            }
            reminder = reminder.add(snapshot.cycleConfig.reminderInterval);
            occurrence++;
          }
        }
      case TimerPhase.awaitingRest:
        final timeout = snapshot.deadlineAtUtc;
        var reminder = snapshot.nextReminderAtUtc;
        var occurrence = 0;
        while (missedRestReminderEnabled &&
            timeout != null &&
            reminder != null &&
            reminder.isBefore(timeout)) {
          if (occurrence < capacity) {
            result.add(
              ScheduledNotification(
                id: _notificationId(snapshot.cycleId, 'restReminder', reminder),
                kind: NotificationKind.restReminder,
                cycleId: snapshot.cycleId,
                expectedPhase: TimerPhase.awaitingRest,
                expectedRevision: snapshot.revision + occurrence + 1,
                scheduledAtUtc: reminder,
                expiresAtUtc: timeout,
                vibrationEnabled: vibrationEnabled,
                hasRestActions: true,
                hasStartWorkAction: false,
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
        if (workReminderEnabled && deadline != null) {
          if (capacity > 0) {
            result.add(
              ScheduledNotification(
                id: _notificationId(snapshot.cycleId, 'restComplete', deadline),
                kind: NotificationKind.restComplete,
                cycleId: snapshot.cycleId,
                expectedPhase:
                    switch (snapshot.cycleConfig.restCompletionBehavior) {
                      RestCompletionBehavior.startWork => TimerPhase.working,
                      RestCompletionBehavior.stopTimer => TimerPhase.idle,
                      RestCompletionBehavior.continueRest =>
                        TimerPhase.awaitingWork,
                    },
                expectedRevision: snapshot.revision + 1,
                scheduledAtUtc: deadline,
                expiresAtUtc: deadline.add(snapshot.cycleConfig.restTimeout),
                vibrationEnabled: vibrationEnabled,
                hasRestActions: false,
                hasStartWorkAction:
                    snapshot.cycleConfig.restCompletionBehavior ==
                    RestCompletionBehavior.continueRest,
              ),
            );
          } else {
            truncated = true;
          }
          if (snapshot.cycleConfig.restCompletionBehavior ==
              RestCompletionBehavior.continueRest) {
            final timeout = deadline.add(snapshot.cycleConfig.restTimeout);
            var reminder = deadline.add(
              snapshot.cycleConfig.missedWorkReminderInterval,
            );
            var occurrence = 0;
            while (missedWorkReminderEnabled && reminder.isBefore(timeout)) {
              if (occurrence + 1 < capacity) {
                result.add(
                  ScheduledNotification(
                    id: _notificationId(
                      snapshot.cycleId,
                      'workReminder',
                      reminder,
                    ),
                    kind: NotificationKind.restComplete,
                    cycleId: snapshot.cycleId,
                    expectedPhase: TimerPhase.awaitingWork,
                    expectedRevision: snapshot.revision + occurrence + 2,
                    scheduledAtUtc: reminder,
                    expiresAtUtc: timeout,
                    vibrationEnabled: vibrationEnabled,
                    hasRestActions: false,
                    hasStartWorkAction: true,
                  ),
                );
              } else {
                truncated = true;
              }
              reminder = reminder.add(
                snapshot.cycleConfig.missedWorkReminderInterval,
              );
              occurrence++;
            }
          }
        }
      case TimerPhase.awaitingWork:
        final timeout = snapshot.deadlineAtUtc;
        var reminder = snapshot.nextReminderAtUtc;
        var occurrence = 0;
        while (missedWorkReminderEnabled &&
            timeout != null &&
            reminder != null &&
            reminder.isBefore(timeout)) {
          if (occurrence < capacity) {
            result.add(
              ScheduledNotification(
                id: _notificationId(snapshot.cycleId, 'workReminder', reminder),
                kind: NotificationKind.restComplete,
                cycleId: snapshot.cycleId,
                expectedPhase: TimerPhase.awaitingWork,
                expectedRevision: snapshot.revision + occurrence + 1,
                scheduledAtUtc: reminder,
                expiresAtUtc: timeout,
                vibrationEnabled: vibrationEnabled,
                hasRestActions: false,
                hasStartWorkAction: true,
              ),
            );
          } else {
            truncated = true;
          }
          reminder = reminder.add(
            snapshot.cycleConfig.missedWorkReminderInterval,
          );
          occurrence++;
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
    await _queue.idle;
    _deliveryFencedIds.clear();
    await _availability.close();
  }
}
