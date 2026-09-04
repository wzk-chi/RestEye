import 'dart:async';

import 'package:rest_eye/core/async/serial_operation_queue.dart';
import 'package:rest_eye/core/clock/app_clock.dart';
import 'package:rest_eye/core/logging/app_logger.dart';
import 'package:rest_eye/features/settings/domain/settings_repository.dart';
import 'package:rest_eye/features/timer/application/ports/screen_state_gateway.dart';
import 'package:rest_eye/features/timer/application/timer_command_dispatcher.dart';
import 'package:rest_eye/features/timer/domain/timer_command.dart';
import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';

/// Pauses and resumes an active work phase when the device is locked.
final class ScreenLockPauseController {
  ScreenLockPauseController(
    this._screenStateGateway,
    this._settingsRepository,
    this._dispatcher,
    this._clock,
    this._logger,
  );

  final ScreenStateGateway _screenStateGateway;
  final SettingsRepository _settingsRepository;
  final TimerCommandDispatcher _dispatcher;
  final AppClock _clock;
  final AppLogger _logger;
  StreamSubscription<ScreenStateChange>? _screenSubscription;
  StreamSubscription<TimerSnapshot>? _snapshotSubscription;
  final _queue = SerialOperationQueue();
  ScreenState _screenState = ScreenState.unknown;
  var _pauseWhenLocked = false;
  var _started = false;
  var _disposed = false;

  Future<void> start() async {
    if (_disposed) return;
    try {
      await _enqueue(() async {
        if (_started) return;
        StreamSubscription<ScreenStateChange>? screenSubscription;
        StreamSubscription<TimerSnapshot>? snapshotSubscription;
        try {
          // Subscribe before reading the current state. The state query is an
          // async boundary, so subscribing afterwards could lose a lock or
          // unlock event in between.
          screenSubscription = _screenStateGateway.changes.listen(
            _onScreenStateChange,
            onError: (Object error) {
              _logger.warning('Screen state stream failed', error: error);
            },
          );
          snapshotSubscription = _dispatcher.snapshots.listen((_) {
            if (_disposed || !_started) return;
            unawaited(_enqueue(_syncForCurrentState));
          });
          _screenState = await _screenStateGateway.currentState();
          final settings = await _settingsRepository.load();
          _pauseWhenLocked = settings.pauseWhenLocked;
          _logger.info(
            'Screen lock pause initialized: $_screenState; '
            'pauseWhenLocked=$_pauseWhenLocked',
          );
          _screenSubscription = screenSubscription;
          _snapshotSubscription = snapshotSubscription;
          screenSubscription = null;
          snapshotSubscription = null;
          _started = true;
          await _syncForCurrentState();
        } catch (error) {
          await screenSubscription?.cancel();
          await snapshotSubscription?.cancel();
          final installedScreenSubscription = _screenSubscription;
          _screenSubscription = null;
          await installedScreenSubscription?.cancel();
          final installedSnapshotSubscription = _snapshotSubscription;
          _snapshotSubscription = null;
          await installedSnapshotSubscription?.cancel();
          _started = false;
          _logger.warning(
            'Screen lock pause initialization failed',
            error: error,
          );
          rethrow;
        }
      });
    } catch (error) {
      _logger.warning('Screen lock pause start failed', error: error);
    }
  }

  Future<void> refreshSettings() async {
    if (_disposed) return;
    try {
      await _enqueue(() async {
        try {
          final settings = await _settingsRepository.load();
          _pauseWhenLocked = settings.pauseWhenLocked;
          if (_started) await _syncForCurrentState();
        } catch (error) {
          _logger.warning(
            'Screen lock pause settings refresh failed',
            error: error,
          );
        }
      });
    } catch (error) {
      _logger.warning('Screen lock pause refresh failed', error: error);
    }
  }

  void _onScreenStateChange(ScreenStateChange change) {
    if (_disposed) return;
    unawaited(
      _enqueue(() async {
        if (!_started) return;
        _screenState = change.state;
        final snapshot = _dispatcher.current;
        _logger.info(
          'Screen state event received: ${change.state}; '
          'pauseWhenLocked=$_pauseWhenLocked; '
          'phase=${snapshot.phase}; '
          'executionStatus=${snapshot.executionStatus}',
        );
        await _syncForCurrentState();
      }),
    );
  }

  Future<void> _syncForCurrentState() async {
    if (!_started || _disposed) return;
    final snapshot = _dispatcher.current;
    if (_screenState == ScreenState.off) {
      if (!_pauseWhenLocked ||
          snapshot.phase != TimerPhase.working ||
          snapshot.executionStatus != ExecutionStatus.active) {
        return;
      }
      final transition = await _dispatcher.dispatch(
        SuspendTimerCommand(
          commandId: _dispatcher.createId('lock-suspend'),
          occurredAtUtc: _clock.utcNow,
          expectedCycleId: snapshot.cycleId,
          expectedPhase: TimerPhase.working,
          expectedRevision: snapshot.revision,
        ),
      );
      _logger.info(
        'Work pause after lock: '
        'outcome=${transition.outcome}; '
        'executionStatus=${transition.snapshot.executionStatus}; '
        'remainingMs=${transition.snapshot.remainingAt(_clock.utcNow).inMilliseconds}',
      );
      return;
    }

    if (_screenState != ScreenState.on && _screenState != ScreenState.dimmed) {
      return;
    }
    if (snapshot.phase != TimerPhase.working ||
        snapshot.executionStatus != ExecutionStatus.suspended) {
      return;
    }
    final transition = await _dispatcher.dispatch(
      ResumeTimerCommand(
        commandId: _dispatcher.createId('unlock-resume'),
        occurredAtUtc: _clock.utcNow,
        expectedCycleId: snapshot.cycleId,
        expectedPhase: TimerPhase.working,
        expectedRevision: snapshot.revision,
      ),
    );
    _logger.info(
      'Work resume after unlock: '
      'outcome=${transition.outcome}; '
      'executionStatus=${transition.snapshot.executionStatus}; '
      'remainingMs=${transition.snapshot.remainingAt(_clock.utcNow).inMilliseconds}',
    );
  }

  Future<void> _enqueue(Future<void> Function() action) {
    return _queue.run(
      action,
      onError: (Object error, StackTrace stackTrace) {
        _logger.warning('Screen lock pause command failed', error: error);
      },
    );
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final screenSubscription = _screenSubscription;
    _screenSubscription = null;
    final snapshotSubscription = _snapshotSubscription;
    _snapshotSubscription = null;
    await screenSubscription?.cancel();
    await snapshotSubscription?.cancel();
    await _queue.idle;
  }
}
