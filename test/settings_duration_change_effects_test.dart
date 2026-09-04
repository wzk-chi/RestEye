import 'package:flutter_test/flutter_test.dart';
import 'package:rest_eye/app/bootstrap/app_settings_change_effects.dart';
import 'package:rest_eye/core/clock/app_clock.dart';
import 'package:rest_eye/core/logging/app_logger.dart';
import 'package:rest_eye/features/settings/application/ports/orientation_gateway.dart';
import 'package:rest_eye/features/settings/application/ports/window_behavior_gateway.dart';
import 'package:rest_eye/features/settings/domain/app_settings.dart';
import 'package:rest_eye/features/settings/domain/settings_repository.dart';
import 'package:rest_eye/features/timer/application/notification_schedule_reconciler.dart';
import 'package:rest_eye/features/timer/application/ports/notification_gateway.dart';
import 'package:rest_eye/features/timer/application/ports/screen_state_gateway.dart';
import 'package:rest_eye/features/timer/application/screen_lock_pause_controller.dart';
import 'package:rest_eye/features/timer/application/timer_command_dispatcher.dart';
import 'package:rest_eye/features/timer/domain/timer_command.dart';
import 'package:rest_eye/features/timer/domain/timer_event.dart';
import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/features/timer/domain/timer_policy.dart';
import 'package:rest_eye/features/timer/domain/timer_repository.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';

void main() {
  final now = DateTime.utc(2026, 9, 4, 8, 5);

  group('settings duration change effects', () {
    for (final testCase in <({String name, TimerPhase phase})>[
      (name: 'work duration stops working timer', phase: TimerPhase.working),
      (name: 'rest duration stops resting timer', phase: TimerPhase.resting),
    ]) {
      test(testCase.name, () async {
        final fixture = await _Fixture.create(
          now: now,
          snapshot: _activeSnapshot(testCase.phase, now),
        );
        addTearDown(fixture.dispose);
        final previous = AppSettings.defaults;
        final current = testCase.phase == TimerPhase.working
            ? previous.copyWith(workDuration: const Duration(minutes: 25))
            : previous.copyWith(restDuration: const Duration(seconds: 30));
        fixture.settings.current = current;

        await fixture.effects.apply(previous, current);

        expect(fixture.dispatcher.current.phase, TimerPhase.idle);
        expect(fixture.timerRepository.commitCount, 1);
      });
    }

    test('duration change does not dispatch stop while idle', () async {
      final fixture = await _Fixture.create(
        now: now,
        snapshot: TimerSnapshot.idle(atUtc: now),
      );
      addTearDown(fixture.dispose);
      final previous = AppSettings.defaults;
      final current = previous.copyWith(
        workDuration: const Duration(minutes: 25),
      );
      fixture.settings.current = current;

      await fixture.effects.apply(previous, current);

      expect(fixture.dispatcher.current.phase, TimerPhase.idle);
      expect(fixture.timerRepository.commitCount, 0);
    });

    test('unrelated setting change keeps active timer running', () async {
      final fixture = await _Fixture.create(
        now: now,
        snapshot: _activeSnapshot(TimerPhase.working, now),
      );
      addTearDown(fixture.dispose);
      final previous = AppSettings.defaults;
      final current = previous.copyWith(
        themePreference: AppThemePreference.dark,
      );
      fixture.settings.current = current;

      await fixture.effects.apply(previous, current);

      expect(fixture.dispatcher.current.phase, TimerPhase.working);
      expect(fixture.timerRepository.commitCount, 0);
    });
  });
}

TimerSnapshot _activeSnapshot(TimerPhase phase, DateTime now) {
  final startedAt = now.subtract(const Duration(minutes: 5));
  return TimerSnapshot(
    cycleId: 'cycle',
    revision: 1,
    phase: phase,
    executionStatus: ExecutionStatus.active,
    startedAtUtc: startedAt,
    deadlineAtUtc: now.add(const Duration(minutes: 15)),
    cycleConfig: TimerCycleConfig.defaults,
  );
}

final class _Fixture {
  _Fixture({
    required this.effects,
    required this.settings,
    required this.timerRepository,
    required this.dispatcher,
    required this.screenLockPauseController,
    required this.notificationReconciler,
    required this.notificationGateway,
  });

  static Future<_Fixture> create({
    required DateTime now,
    required TimerSnapshot snapshot,
  }) async {
    final clock = _FakeClock(now);
    final settings = _FakeSettingsRepository();
    final timerRepository = _FakeTimerRepository(snapshot);
    final notificationGateway = _FakeNotificationGateway();
    final notificationReconciler = NotificationScheduleReconciler(
      notificationGateway,
      settings,
      timerRepository,
      const ConsoleAppLogger(),
      clock,
    );
    final dispatcher = TimerCommandDispatcher(
      timerRepository,
      settings,
      clock,
      const ConsoleAppLogger(),
      notificationReconciler,
    );
    await dispatcher.initialize();
    final screenLockPauseController = ScreenLockPauseController(
      const _FakeScreenStateGateway(),
      settings,
      dispatcher,
      clock,
      const ConsoleAppLogger(),
    );
    final effects = AppSettingsChangeEffects(
      screenLockPauseController,
      notificationReconciler,
      dispatcher,
      const _FakeOrientationGateway(),
      const _FakeWindowBehaviorGateway(),
    );
    return _Fixture(
      effects: effects,
      settings: settings,
      timerRepository: timerRepository,
      dispatcher: dispatcher,
      screenLockPauseController: screenLockPauseController,
      notificationReconciler: notificationReconciler,
      notificationGateway: notificationGateway,
    );
  }

  final AppSettingsChangeEffects effects;
  final _FakeSettingsRepository settings;
  final _FakeTimerRepository timerRepository;
  final TimerCommandDispatcher dispatcher;
  final ScreenLockPauseController screenLockPauseController;
  final NotificationScheduleReconciler notificationReconciler;
  final _FakeNotificationGateway notificationGateway;

  Future<void> dispose() async {
    await screenLockPauseController.dispose();
    await dispatcher.dispose();
    await notificationReconciler.dispose();
    await notificationGateway.dispose();
  }
}

final class _FakeClock implements AppClock {
  const _FakeClock(this.utcNow);

  @override
  final DateTime utcNow;

  @override
  Duration get elapsed => Duration.zero;
}

final class _FakeSettingsRepository implements SettingsRepository {
  AppSettings current = AppSettings.defaults;

  @override
  Future<AppSettings> load() async => current;

  @override
  Future<void> save(AppSettings settings) async => current = settings;
}

final class _FakeTimerRepository implements TimerRepository {
  _FakeTimerRepository(this.snapshot);

  TimerSnapshot snapshot;
  int commitCount = 0;

  @override
  Future<void> commit({
    required int expectedRevision,
    required TimerSnapshot snapshot,
    required List<TimerEvent> events,
    String? processedCommandId,
    DateTime? processedAtUtc,
  }) async {
    if (this.snapshot.revision != expectedRevision) {
      throw const TimerCommitConflict();
    }
    this.snapshot = snapshot;
    commitCount++;
  }

  @override
  Future<void> enqueueCommand(TimerCommand command) async {}

  @override
  Future<List<TimerCommand>> loadPendingCommands() async => const [];

  @override
  Future<TimerSnapshot> loadSnapshot() async => snapshot;

  @override
  Future<void> markCommandStale(String commandId, DateTime atUtc) async {}
}

final class _FakeNotificationGateway implements NotificationGateway {
  var _disposed = false;

  @override
  Stream<NotificationActionRequest> get actions => const Stream.empty();

  @override
  int get maxPendingNotificationRequests => 256;

  @override
  Future<Set<int>> activeNotificationIds() async => const {};

  @override
  Future<void> cancel(int notificationId) async {}

  @override
  void claimActionNotification(int notificationId) {}

  @override
  Future<void> dispose() async => _disposed = true;

  @override
  Future<void> initialize() async {}

  @override
  Future<Set<int>> pendingNotificationIds() async => const {};

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
  }) async {
    if (_disposed) throw StateError('Notification gateway is disposed');
  }

  @override
  Future<NotificationActionRequest?> takeLaunchAction() async => null;
}

final class _FakeScreenStateGateway implements ScreenStateGateway {
  const _FakeScreenStateGateway();

  @override
  Stream<ScreenStateChange> get changes => const Stream.empty();

  @override
  Future<ScreenState> currentState() async => ScreenState.on;
}

final class _FakeOrientationGateway implements OrientationGateway {
  const _FakeOrientationGateway();

  @override
  Future<void> setFixedPortrait({required bool enabled}) async {}
}

final class _FakeWindowBehaviorGateway implements WindowBehaviorGateway {
  const _FakeWindowBehaviorGateway();

  @override
  Future<void> setMinimizeToTrayOnClose({required bool enabled}) async {}

  @override
  Future<void> setTrayMenu({
    required String appTitle,
    required String openApp,
    required String exitApp,
    required List<WindowTrayMenuItem> items,
  }) async {}

  @override
  Stream<WindowTrayMenuAction> get trayActions => const Stream.empty();
}
