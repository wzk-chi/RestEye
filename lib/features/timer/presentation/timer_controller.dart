import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rest_eye/core/clock/app_clock_provider.dart';
import 'package:rest_eye/core/error/app_failure.dart';
import 'package:rest_eye/features/settings/application/settings_dependencies.dart';
import 'package:rest_eye/features/timer/application/ports/notification_gateway.dart';
import 'package:rest_eye/features/timer/application/ports/platform_capabilities.dart';
import 'package:rest_eye/features/timer/application/timer_cycle_config_factory.dart';
import 'package:rest_eye/features/timer/application/timer_dependencies.dart';
import 'package:rest_eye/features/timer/application/timer_runtime.dart';
import 'package:rest_eye/features/timer/domain/timer_command.dart';
import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';

final class TimerViewState {
  const TimerViewState({
    required this.snapshot,
    required this.remaining,
    required this.displayDuration,
    required this.progress,
    required this.notificationPermission,
    required this.notificationCapability,
    this.busy = false,
    this.failureCode,
  });

  final TimerSnapshot snapshot;
  final Duration remaining;
  final Duration displayDuration;
  final double progress;
  final NotificationPermissionStatus notificationPermission;
  final CapabilityAvailability notificationCapability;
  final bool busy;
  final String? failureCode;

  TimerViewState copyWith({
    TimerSnapshot? snapshot,
    Duration? remaining,
    Duration? displayDuration,
    double? progress,
    NotificationPermissionStatus? notificationPermission,
    CapabilityAvailability? notificationCapability,
    bool? busy,
    String? failureCode,
    bool clearFailure = false,
  }) {
    return TimerViewState(
      snapshot: snapshot ?? this.snapshot,
      remaining: remaining ?? this.remaining,
      displayDuration: displayDuration ?? this.displayDuration,
      progress: progress ?? this.progress,
      notificationPermission:
          notificationPermission ?? this.notificationPermission,
      notificationCapability:
          notificationCapability ?? this.notificationCapability,
      busy: busy ?? this.busy,
      failureCode: clearFailure ? null : failureCode ?? this.failureCode,
    );
  }
}

final timerControllerProvider =
    NotifierProvider<TimerController, TimerViewState>(TimerController.new);

final class TimerController extends Notifier<TimerViewState> {
  @override
  TimerViewState build() {
    final dispatcher = ref.watch(timerCommandDispatcherProvider);
    final runtime = ref.watch(timerRuntimeProvider);
    final notificationReconciler = ref.watch(notificationReconcilerProvider);
    final clock = ref.watch(appClockProvider);
    final snapshot = dispatcher.current;
    final tickSubscription = runtime.ticks.listen(_onTick);
    final capabilitySubscription = notificationReconciler.availability.listen((
      availability,
    ) {
      if (!ref.mounted) return;
      state = state.copyWith(notificationCapability: availability);
    });
    ref.onDispose(() {
      unawaited(tickSubscription.cancel());
      unawaited(capabilitySubscription.cancel());
    });
    Future.microtask(_loadNotificationPermission);
    return TimerViewState(
      snapshot: snapshot,
      remaining: snapshot.remainingAt(clock.utcNow),
      displayDuration: snapshot.displayDurationAt(clock.utcNow),
      progress: snapshot.progressAt(clock.utcNow),
      notificationPermission: NotificationPermissionStatus.notDetermined,
      notificationCapability: notificationReconciler.currentAvailability,
    );
  }

  void _onTick(TimerRuntimeTick tick) {
    if (!ref.mounted) return;
    state = state.copyWith(
      snapshot: tick.snapshot,
      remaining: tick.remaining,
      displayDuration: tick.displayDuration,
      progress: tick.progress,
    );
  }

  Future<void> _loadNotificationPermission() async {
    try {
      final status = await ref
          .read(notificationGatewayProvider)
          .permissionStatus();
      if (!ref.mounted) return;
      state = state.copyWith(notificationPermission: status);
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        notificationPermission: NotificationPermissionStatus.unavailable,
        notificationCapability: CapabilityAvailability.degraded,
      );
    }
  }

  Future<void> requestNotificationPermission() async {
    if (state.busy) return;
    state = state.copyWith(busy: true, clearFailure: true);
    try {
      final status = await ref
          .read(notificationGatewayProvider)
          .requestPermission();
      if (!ref.mounted) return;
      state = state.copyWith(notificationPermission: status, busy: false);
    } on AppFailure catch (failure) {
      if (!ref.mounted) return;
      state = state.copyWith(
        notificationPermission: NotificationPermissionStatus.unavailable,
        notificationCapability: CapabilityAvailability.degraded,
        busy: false,
        failureCode: failure.code,
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        notificationPermission: NotificationPermissionStatus.unavailable,
        notificationCapability: CapabilityAvailability.degraded,
        busy: false,
        failureCode: 'unexpected',
      );
    }
  }

  Future<void> startWork() async {
    await _run(() async {
      final settings = await ref.read(settingsRepositoryProvider).load();
      final dispatcher = ref.read(timerCommandDispatcherProvider);
      final snapshot = dispatcher.current;
      return dispatcher.dispatch(
        StartWorkCommand(
          commandId: dispatcher.createId('start-work'),
          occurredAtUtc: ref.read(appClockProvider).utcNow,
          cycleId: dispatcher.createId('cycle'),
          cycleConfig: timerCycleConfigFromSettings(settings),
          expectedCycleId: snapshot.cycleId,
          expectedRevision: snapshot.revision,
        ),
      );
    });
  }

  Future<void> startRest() async {
    await _run(() {
      final dispatcher = ref.read(timerCommandDispatcherProvider);
      final snapshot = dispatcher.current;
      return dispatcher.dispatch(
        StartRestCommand(
          commandId: dispatcher.createId('start-rest'),
          occurredAtUtc: ref.read(appClockProvider).utcNow,
          expectedCycleId: snapshot.cycleId,
        ),
      );
    });
  }

  Future<void> resumeWork() async {
    await _run(() {
      final dispatcher = ref.read(timerCommandDispatcherProvider);
      final snapshot = dispatcher.current;
      return dispatcher.dispatch(
        ResumeTimerCommand(
          commandId: dispatcher.createId('resume-work'),
          occurredAtUtc: ref.read(appClockProvider).utcNow,
          expectedCycleId: snapshot.cycleId,
          expectedPhase: TimerPhase.working,
          expectedRevision: snapshot.revision,
        ),
      );
    });
  }

  Future<void> skipRest() async {
    await _run(() async {
      final settings = await ref.read(settingsRepositoryProvider).load();
      final dispatcher = ref.read(timerCommandDispatcherProvider);
      final snapshot = dispatcher.current;
      return dispatcher.dispatch(
        SkipRestCommand(
          commandId: dispatcher.createId('skip-rest'),
          occurredAtUtc: ref.read(appClockProvider).utcNow,
          expectedCycleId: snapshot.cycleId,
          nextCycleId: dispatcher.createId('cycle'),
          nextCycleConfig: timerCycleConfigFromSettings(settings),
        ),
      );
    });
  }

  Future<void> stop() async {
    await _run(() {
      final dispatcher = ref.read(timerCommandDispatcherProvider);
      final snapshot = dispatcher.current;
      return dispatcher.dispatch(
        StopTimerCommand(
          commandId: dispatcher.createId('stop'),
          occurredAtUtc: ref.read(appClockProvider).utcNow,
          expectedCycleId: snapshot.cycleId,
        ),
      );
    });
  }

  Future<void> _run(Future<Object?> Function() action) async {
    if (state.busy) return;
    state = state.copyWith(busy: true, clearFailure: true);
    try {
      await action();
      if (!ref.mounted) return;
      state = state.copyWith(busy: false);
    } on AppFailure catch (failure) {
      if (!ref.mounted) return;
      state = state.copyWith(busy: false, failureCode: failure.code);
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(busy: false, failureCode: 'unexpected');
    }
  }
}
