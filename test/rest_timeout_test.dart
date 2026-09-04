import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rest_eye/core/clock/app_clock.dart';
import 'package:rest_eye/core/logging/app_logger.dart';
import 'package:rest_eye/features/settings/domain/app_settings.dart';
import 'package:rest_eye/features/settings/domain/settings_repository.dart';
import 'package:rest_eye/features/timer/application/notification_schedule_reconciler.dart';
import 'package:rest_eye/features/timer/application/ports/notification_gateway.dart';
import 'package:rest_eye/features/timer/domain/timer_command.dart';
import 'package:rest_eye/features/timer/domain/timer_event.dart';
import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/features/timer/domain/timer_policy.dart';
import 'package:rest_eye/features/timer/domain/timer_reducer.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';
import 'package:rest_eye/platform/notifications/local_notification_gateway.dart';

void main() {
  final restStartedAt = DateTime.utc(2026, 9, 4, 8);

  group('rest overtime', () {
    test('continue rest enters awaiting work with reminders and timeout', () {
      final config = _config();
      final restDeadline = restStartedAt.add(config.restDuration);
      final transition = TimerReducer.reduce(
        _restingSnapshot(config, restStartedAt),
        ReachDeadlineCommand(
          commandId: 'deadline',
          occurredAtUtc: restDeadline,
          nextCycleId: 'next',
          nextCycleConfig: config,
        ),
      );

      expect(transition.snapshot.phase, TimerPhase.awaitingWork);
      expect(transition.snapshot.startedAtUtc, restDeadline);
      expect(
        transition.snapshot.nextReminderAtUtc,
        restDeadline.add(config.missedWorkReminderInterval),
      );
      expect(
        transition.snapshot.deadlineAtUtc,
        restDeadline.add(config.restTimeout),
      );
      expect(
        transition.snapshot.displayDurationAt(
          restDeadline.add(const Duration(seconds: 5)),
        ),
        config.restDuration + const Duration(seconds: 5),
      );
      expect(transition.events.map((event) => event.type), [
        TimerEventType.workPrompted,
      ]);
    });

    test('rest overtime counts as rest and starts work at its limit', () {
      final config = _config();
      final restDeadline = restStartedAt.add(config.restDuration);
      final awaitingWork = TimerReducer.reduce(
        _restingSnapshot(config, restStartedAt),
        ReachDeadlineCommand(
          commandId: 'rest-deadline',
          occurredAtUtc: restDeadline,
          nextCycleId: 'unused',
          nextCycleConfig: config,
        ),
      ).snapshot;
      final timeoutAt = restDeadline.add(config.restTimeout);

      final transition = TimerReducer.reduce(
        awaitingWork,
        ReconcileTimerCommand(
          commandId: 'rest-timeout',
          occurredAtUtc: timeoutAt,
          nextCycleId: 'next',
          nextCycleConfig: config,
        ),
      );

      expect(transition.snapshot.phase, TimerPhase.working);
      expect(transition.snapshot.cycleId, 'next');
      expect(transition.events.map((event) => event.type), [
        TimerEventType.workReminder,
        TimerEventType.workReminder,
        TimerEventType.restCompleted,
        TimerEventType.workTimedOut,
        TimerEventType.workStarted,
      ]);
      final completedRest = transition.events.singleWhere(
        (event) => event.type == TimerEventType.restCompleted,
      );
      expect(completedRest.duration, config.restDuration + config.restTimeout);
    });

    test('rest overtime can end timing at its limit', () {
      final config = _config(restTimeoutBehavior: TimeoutBehavior.stopTimer);
      final restDeadline = restStartedAt.add(config.restDuration);
      final awaitingWork = TimerReducer.reduce(
        _restingSnapshot(config, restStartedAt),
        ReachDeadlineCommand(
          commandId: 'rest-deadline-stop',
          occurredAtUtc: restDeadline,
          nextCycleId: 'unused',
          nextCycleConfig: config,
        ),
      ).snapshot;

      final transition = TimerReducer.reduce(
        awaitingWork,
        ReconcileTimerCommand(
          commandId: 'rest-timeout-stop',
          occurredAtUtc: restDeadline.add(config.restTimeout),
          nextCycleId: 'unused',
          nextCycleConfig: config,
        ),
      );

      expect(transition.snapshot.phase, TimerPhase.idle);
      expect(
        transition.events.map((event) => event.type),
        containsAll([
          TimerEventType.restCompleted,
          TimerEventType.workTimedOut,
        ]),
      );
    });

    test('starting work during overtime records the full rest', () {
      final config = _config();
      final restDeadline = restStartedAt.add(config.restDuration);
      final awaitingWork = TimerReducer.reduce(
        _restingSnapshot(config, restStartedAt),
        ReachDeadlineCommand(
          commandId: 'rest-deadline-manual',
          occurredAtUtc: restDeadline,
          nextCycleId: 'unused',
          nextCycleConfig: config,
        ),
      ).snapshot;
      final startedWorkAt = restDeadline.add(const Duration(seconds: 30));

      final transition = TimerReducer.reduce(
        awaitingWork,
        CompleteRestCommand(
          commandId: 'start-work',
          occurredAtUtc: startedWorkAt,
          expectedCycleId: awaitingWork.cycleId,
          nextCycleId: 'next',
          nextCycleConfig: config,
        ),
      );

      expect(transition.snapshot.phase, TimerPhase.working);
      expect(transition.snapshot.cycleId, 'next');
      final completedRest = transition.events.singleWhere(
        (event) => event.type == TimerEventType.restCompleted,
      );
      expect(
        completedRest.duration,
        config.restDuration + const Duration(seconds: 30),
      );
    });

    test('work reminder is scheduled when planned rest time is used up', () {
      final config = _config();
      final restDeadline = restStartedAt.add(config.restDuration);
      final reconciler = NotificationScheduleReconciler(
        _FakeNotificationGateway(),
        _FakeSettingsRepository(),
        const ConsoleAppLogger(),
        _FakeClock(restStartedAt),
      );

      final plan = reconciler.derivePlan(
        _restingSnapshot(config, restStartedAt),
        vibrationEnabled: true,
        workReminderEnabled: true,
        restReminderEnabled: true,
        missedRestReminderEnabled: true,
        missedWorkReminderEnabled: true,
        maxPendingRequests: 256,
      );

      expect(plan.items, hasLength(1));
      expect(plan.items.single.kind, NotificationKind.restComplete);
      expect(plan.items.single.scheduledAtUtc, restDeadline);
      expect(plan.items.single.expectedPhase, TimerPhase.awaitingWork);
      expect(plan.items.single.hasStartWorkAction, isTrue);

      final awaitingWork = TimerReducer.reduce(
        _restingSnapshot(config, restStartedAt),
        ReachDeadlineCommand(
          commandId: 'notification-deadline',
          occurredAtUtc: restDeadline,
          nextCycleId: 'unused',
          nextCycleConfig: config,
        ),
      ).snapshot;
      final repeatPlan = reconciler.derivePlan(
        awaitingWork,
        vibrationEnabled: true,
        workReminderEnabled: true,
        restReminderEnabled: true,
        missedRestReminderEnabled: true,
        missedWorkReminderEnabled: true,
        maxPendingRequests: 256,
      );
      expect(repeatPlan.items.map((item) => item.scheduledAtUtc), [
        restDeadline.add(const Duration(minutes: 1)),
        restDeadline.add(const Duration(minutes: 2)),
      ]);
      expect(repeatPlan.items.every((item) => item.hasStartWorkAction), isTrue);
    });

    test('work reminder is sent for every rest completion behavior', () {
      final reconciler = NotificationScheduleReconciler(
        _FakeNotificationGateway(),
        _FakeSettingsRepository(),
        const ConsoleAppLogger(),
        _FakeClock(restStartedAt),
      );

      for (final behavior in RestCompletionBehavior.values) {
        final config = _config(restCompletionBehavior: behavior);
        final plan = reconciler.derivePlan(
          _restingSnapshot(config, restStartedAt),
          vibrationEnabled: true,
          workReminderEnabled: true,
          restReminderEnabled: true,
          missedRestReminderEnabled: true,
          missedWorkReminderEnabled: true,
          maxPendingRequests: 256,
        );

        expect(
          plan.items.single.kind,
          NotificationKind.restComplete,
          reason: 'rest completion behavior: ${behavior.name}',
        );
        expect(
          plan.items.single.scheduledAtUtc,
          restStartedAt.add(config.restDuration),
          reason: 'rest completion behavior: ${behavior.name}',
        );
        expect(
          plan.items.single.hasStartWorkAction,
          behavior == RestCompletionBehavior.continueRest,
          reason: 'rest completion behavior: ${behavior.name}',
        );
      }
    });

    test('start work notification action is parsed', () {
      final action = parseLocalNotificationActionResponse(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotificationAction,
          actionId: 'startWork',
          payload:
              '{"cycleId":"cycle","expectedPhase":"awaitingWork",'
              '"expectedRevision":2}',
        ),
        _FakeClock(restStartedAt),
      );

      expect(action, isNotNull);
      expect(action!.type, NotificationActionType.startWork);
      expect(action.cycleId, 'cycle');
      expect(action.expectedPhase, TimerPhase.awaitingWork);
      expect(action.expectedRevision, 2);
    });
  });
}

TimerCycleConfig _config({
  TimeoutBehavior restTimeoutBehavior = TimeoutBehavior.nextCycle,
  RestCompletionBehavior restCompletionBehavior =
      RestCompletionBehavior.continueRest,
}) => TimerCycleConfig(
  workDuration: Duration(minutes: 20),
  restDuration: Duration(seconds: 20),
  reminderInterval: Duration(minutes: 3),
  reminderTimeout: Duration(minutes: 10),
  missedWorkReminderInterval: Duration(minutes: 1),
  restTimeout: Duration(minutes: 3),
  restCompletionBehavior: restCompletionBehavior,
  restTimeoutBehavior: restTimeoutBehavior,
);

TimerSnapshot _restingSnapshot(TimerCycleConfig config, DateTime startedAt) =>
    TimerSnapshot(
      cycleId: 'cycle',
      revision: 1,
      phase: TimerPhase.resting,
      executionStatus: ExecutionStatus.active,
      startedAtUtc: startedAt,
      deadlineAtUtc: startedAt.add(config.restDuration),
      cycleConfig: config,
    );

final class _FakeClock implements AppClock {
  const _FakeClock(this.utcNow);

  @override
  final DateTime utcNow;

  @override
  Duration get elapsed => Duration.zero;
}

final class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<AppSettings> load() async => AppSettings.defaults;

  @override
  Future<void> save(AppSettings settings) async {}
}

final class _FakeNotificationGateway implements NotificationGateway {
  @override
  Stream<NotificationActionRequest> get actions => const Stream.empty();

  @override
  int get maxPendingNotificationRequests => 256;

  @override
  Future<Set<int>> activeNotificationIds() async => {};

  @override
  Future<void> cancel(int notificationId) async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<Set<int>> pendingNotificationIds() async => {};

  @override
  Future<NotificationPermissionStatus> permissionStatus() async =>
      NotificationPermissionStatus.granted;

  @override
  Future<NotificationPermissionStatus> requestPermission() async =>
      NotificationPermissionStatus.granted;

  @override
  Future<void> schedule(
    ScheduledNotification notification, {
    required AppSettings settings,
  }) async {}

  @override
  Future<NotificationActionRequest?> takeLaunchAction() async => null;
}
