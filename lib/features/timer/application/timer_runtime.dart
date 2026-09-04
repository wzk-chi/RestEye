import 'dart:async';

import 'package:rest_eye/core/clock/app_clock.dart';
import 'package:rest_eye/core/logging/app_logger.dart';
import 'package:rest_eye/features/settings/domain/settings_repository.dart';
import 'package:rest_eye/features/timer/application/ports/lifecycle_gateway.dart';
import 'package:rest_eye/features/timer/application/timer_command_dispatcher.dart';
import 'package:rest_eye/features/timer/application/timer_cycle_config_factory.dart';
import 'package:rest_eye/features/timer/domain/timer_command.dart';
import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/features/timer/domain/timer_policy.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';

final class TimerRuntimeTick {
  const TimerRuntimeTick({
    required this.snapshot,
    required this.remaining,
    required this.displayDuration,
    required this.displayElapsed,
    required this.progress,
  });

  final TimerSnapshot snapshot;
  final Duration remaining;
  final Duration displayDuration;
  final Duration displayElapsed;
  final double progress;
}

final class TimerRuntime {
  static const _debugLogging = !bool.fromEnvironment('dart.vm.product');

  TimerRuntime(
    this._dispatcher,
    this._settingsRepository,
    this._clock,
    this._lifecycleGateway,
    this._logger,
  );

  final TimerCommandDispatcher _dispatcher;
  final SettingsRepository _settingsRepository;
  final AppClock _clock;
  final LifecycleGateway _lifecycleGateway;
  final AppLogger _logger;
  final _ticks = StreamController<TimerRuntimeTick>.broadcast();
  StreamSubscription<TimerSnapshot>? _snapshotSubscription;
  StreamSubscription<AppLifecycleEvent>? _lifecycleSubscription;
  Timer? _deadlineTimer;
  Timer? _displayTimer;
  Timer? _retryTimer;
  TimerSnapshot _snapshot = TimerSnapshot.idle();
  Duration _anchorRemaining = Duration.zero;
  Duration _anchorDisplayElapsed = Duration.zero;
  Duration _anchorElapsed = Duration.zero;
  Future<void> _reconcileTail = Future.value();
  Future<void> _lifecycleStopTail = Future.value();
  var _deadlineRetryAttempt = 0;
  var _started = false;
  var _disposed = false;

  Stream<TimerRuntimeTick> get ticks => _ticks.stream;

  void start() {
    if (_started || _disposed) return;
    _started = true;
    _lifecycleGateway.start();
    _snapshotSubscription = _dispatcher.snapshots.listen(_onSnapshot);
    _lifecycleSubscription = _lifecycleGateway.events.listen(_onLifecycleEvent);
    _onSnapshot(_dispatcher.current);
  }

  void _onLifecycleEvent(AppLifecycleEvent event) {
    switch (event) {
      case AppLifecycleEvent.resumed:
        _requestReconcile();
      case AppLifecycleEvent.detached:
        _queueDetachedStop();
      case AppLifecycleEvent.inactive ||
          AppLifecycleEvent.paused ||
          AppLifecycleEvent.hidden:
        break;
    }
  }

  void _queueDetachedStop() {
    final operation = _lifecycleStopTail.then((_) async {
      try {
        await _dispatcher.stopIfActive(source: 'detached');
      } catch (error, stackTrace) {
        _logger.error(
          'Timer shutdown reconciliation failed',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });
    _lifecycleStopTail = operation;
    unawaited(operation);
  }

  void _onSnapshot(TimerSnapshot snapshot) {
    _snapshot = snapshot;
    _anchorRemaining = snapshot.remainingAt(_clock.utcNow);
    _anchorDisplayElapsed = snapshot.displayElapsedAt(_clock.utcNow);
    _anchorElapsed = _clock.elapsed;
    _retryTimer?.cancel();
    _retryTimer = null;
    _deadlineRetryAttempt = 0;
    if (_debugLogging) {
      _logger.info(
        'Timer runtime snapshot: phase=${snapshot.phase}; '
        'executionStatus=${snapshot.executionStatus}; '
        'remainingMs=${_anchorRemaining.inMilliseconds}',
      );
    }
    _scheduleDeadline(snapshot);
    _updateDisplayTimer();
    _emitTick();
  }

  void _updateDisplayTimer() {
    final shouldTick =
        _snapshot.isActive &&
        _snapshot.executionStatus == ExecutionStatus.active;
    if (!shouldTick) {
      _displayTimer?.cancel();
      _displayTimer = null;
      return;
    }
    if (_displayTimer != null) return;
    _displayTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _emitTick(),
    );
  }

  void _scheduleDeadline(TimerSnapshot snapshot) {
    _deadlineTimer?.cancel();
    final dueAt = snapshot.nextDueAtUtc;
    if (dueAt == null) return;
    final delay = dueAt.difference(_clock.utcNow);
    _deadlineTimer = Timer(
      delay.isNegative ? Duration.zero : delay,
      _requestReconcile,
    );
  }

  void _requestReconcile() {
    if (_disposed) return;
    final operation = _reconcileTail.then((_) async {
      try {
        await _reconcileNow();
        _deadlineRetryAttempt = 0;
      } catch (error, stackTrace) {
        _logger.error(
          'Timer deadline reconciliation failed',
          error: error,
          stackTrace: stackTrace,
        );
        _scheduleRetry();
      }
    });
    _reconcileTail = operation.then<void>((_) {}, onError: (_, _) {});
  }

  void _scheduleRetry() {
    if (_disposed || _retryTimer != null) return;
    const maxAttempts = 5;
    if (_deadlineRetryAttempt >= maxAttempts) {
      _logger.warning(
        'Timer deadline reconciliation abandoned after $maxAttempts retries',
      );
      return;
    }
    _deadlineRetryAttempt++;
    final delay = Duration(seconds: 1 << (_deadlineRetryAttempt - 1));
    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      _requestReconcile();
    });
  }

  Future<void> _reconcileNow() async {
    final snapshot = await _dispatcher.refreshFromRepository();
    final settings = await _settingsRepository.load();
    await _dispatcher.dispatch(
      ReconcileTimerCommand(
        commandId: _dispatcher.createId('deadline'),
        occurredAtUtc: _clock.utcNow,
        nextCycleId: _dispatcher.createId('cycle'),
        nextCycleConfig: timerCycleConfigFromSettings(settings),
        expectedCycleId: snapshot.cycleId,
      ),
    );
  }

  void _emitTick() {
    if (_disposed) return;
    final elapsedSinceAnchor = _clock.elapsed - _anchorElapsed;
    final calculated = _anchorRemaining - elapsedSinceAnchor;
    final remaining = _snapshot.executionStatus == ExecutionStatus.suspended
        ? _anchorRemaining
        : calculated.isNegative
        ? Duration.zero
        : calculated;
    final displayElapsed =
        _snapshot.executionStatus == ExecutionStatus.suspended
        ? _anchorDisplayElapsed
        : (_anchorDisplayElapsed + elapsedSinceAnchor);
    // Both the countdown and the positive elapsed readout now derive from
    // the same monotonic tick.  Reading UTC again here used to make the UI
    // jump when the system clock was adjusted while the process stayed alive.
    final displayDuration =
        _snapshot.phase == TimerPhase.resting &&
            _snapshot.cycleConfig.restCompletionBehavior ==
                RestCompletionBehavior.continueRest
        ? displayElapsed
        : _snapshot.displayDurationForRemaining(remaining);
    if (_debugLogging &&
        _snapshot.executionStatus == ExecutionStatus.suspended) {
      _logger.info(
        'Timer runtime suspended tick: '
        'remainingMs=${remaining.inMilliseconds}; '
        'displayMs=${_snapshot.displayDurationForRemaining(remaining).inMilliseconds}',
      );
    }
    _ticks.add(
      TimerRuntimeTick(
        snapshot: _snapshot,
        remaining: remaining,
        displayDuration: displayDuration,
        displayElapsed: displayElapsed.isNegative
            ? Duration.zero
            : displayElapsed,
        progress: _snapshot.progressForRemaining(remaining),
      ),
    );
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _deadlineTimer?.cancel();
    _displayTimer?.cancel();
    _retryTimer?.cancel();
    await _snapshotSubscription?.cancel();
    await _lifecycleSubscription?.cancel();
    await _lifecycleStopTail;
    await _reconcileTail;
    await _lifecycleGateway.dispose();
    await _ticks.close();
  }
}
