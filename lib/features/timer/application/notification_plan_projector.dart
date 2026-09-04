import 'package:rest_eye/features/timer/application/ports/notification_gateway.dart';
import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/features/timer/domain/timer_policy.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';

final class NotificationPlan {
  const NotificationPlan({required this.items, required this.truncated});

  final List<ScheduledNotification> items;
  final bool truncated;
}

/// Notification settings that affect the desired schedule.
///
/// Keeping this value separate from `AppSettings` makes plan projection a
/// pure operation over only the inputs that can change its result.
final class NotificationPlanPreferences {
  const NotificationPlanPreferences({
    required this.vibrationEnabled,
    required this.workReminderEnabled,
    required this.restReminderEnabled,
    required this.missedRestReminderEnabled,
    required this.missedWorkReminderEnabled,
  });

  final bool vibrationEnabled;
  final bool workReminderEnabled;
  final bool restReminderEnabled;
  final bool missedRestReminderEnabled;
  final bool missedWorkReminderEnabled;
}

/// Projects durable timer state into the notifications the platform should
/// contain. It performs no I/O and does not track what the platform delivered.
final class NotificationPlanProjector {
  const NotificationPlanProjector();

  NotificationPlan project(
    TimerSnapshot snapshot, {
    required NotificationPlanPreferences preferences,
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
        if (preferences.restReminderEnabled && deadline != null) {
          if (capacity > 0) {
            result.add(
              ScheduledNotification(
                id: _notificationId(snapshot.cycleId, 'workComplete', deadline),
                kind: NotificationKind.workComplete,
                cycleId: snapshot.cycleId,
                expectedPhase: TimerPhase.awaitingRest,
                scheduledAtUtc: deadline,
                expiresAtUtc: deadline.add(
                  snapshot.cycleConfig.reminderTimeout,
                ),
                vibrationEnabled: preferences.vibrationEnabled,
                hasStartRestAction: true,
                hasStartWorkAction: false,
              ),
            );
          } else {
            truncated = true;
          }
        }
        if (deadline != null) {
          // Schedule the finite waiting window while the process is alive so
          // native alarms can continue after the Dart isolate is reclaimed.
          final timeout = deadline.add(snapshot.cycleConfig.reminderTimeout);
          var reminder = deadline.add(snapshot.cycleConfig.reminderInterval);
          var occurrence = 0;
          while (preferences.missedRestReminderEnabled &&
              reminder.isBefore(timeout)) {
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
                  scheduledAtUtc: reminder,
                  expiresAtUtc: timeout,
                  vibrationEnabled: preferences.vibrationEnabled,
                  hasStartRestAction: true,
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
        while (preferences.missedRestReminderEnabled &&
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
                scheduledAtUtc: reminder,
                expiresAtUtc: timeout,
                vibrationEnabled: preferences.vibrationEnabled,
                hasStartRestAction: true,
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
        if (preferences.workReminderEnabled && deadline != null) {
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
                scheduledAtUtc: deadline,
                expiresAtUtc: deadline.add(snapshot.cycleConfig.restTimeout),
                vibrationEnabled: preferences.vibrationEnabled,
                hasStartRestAction: false,
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
            while (preferences.missedWorkReminderEnabled &&
                reminder.isBefore(timeout)) {
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
                    scheduledAtUtc: reminder,
                    expiresAtUtc: timeout,
                    vibrationEnabled: preferences.vibrationEnabled,
                    hasStartRestAction: false,
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
        while (preferences.missedWorkReminderEnabled &&
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
                scheduledAtUtc: reminder,
                expiresAtUtc: timeout,
                vibrationEnabled: preferences.vibrationEnabled,
                hasStartRestAction: false,
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
}
