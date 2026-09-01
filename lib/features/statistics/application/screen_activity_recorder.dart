import 'dart:async';

import 'package:rest_eye/core/clock/app_clock.dart';
import 'package:rest_eye/core/logging/app_logger.dart';
import 'package:rest_eye/features/statistics/domain/statistics_repository.dart';
import 'package:rest_eye/features/timer/application/ports/platform_capabilities.dart';
import 'package:rest_eye/features/timer/application/ports/screen_state_gateway.dart';

final class ScreenActivityRecorder {
  ScreenActivityRecorder(
    this._gateway,
    this._repository,
    this._clock,
    this._logger,
  );

  final ScreenStateGateway _gateway;
  final StatisticsRepository _repository;
  final AppClock _clock;
  final AppLogger _logger;
  final _availability = StreamController<CapabilityAvailability>.broadcast();
  final _changes = StreamController<void>.broadcast();
  StreamSubscription<ScreenStateChange>? _subscription;
  Future<void> _tail = Future.value();
  CapabilityAvailability _currentAvailability =
      CapabilityAvailability.unavailable;
  ScreenState? _lastAppliedState;
  var _started = false;
  var _disposed = false;

  Stream<CapabilityAvailability> get availability => _availability.stream;
  CapabilityAvailability get currentAvailability => _currentAvailability;
  Stream<void> get changes => _changes.stream;

  Future<void> start() async {
    if (_started || _disposed) return;
    _started = true;
    _subscription = _gateway.changes.listen(
      (change) => unawaited(
        _enqueue(
          () => _applyState(change.state, change.occurredAtUtc),
          operation: 'screen change',
        ),
      ),
      onError: (Object error, StackTrace stackTrace) {
        _logger.warning('Screen state stream failed', error: error);
        _publishAvailability(CapabilityAvailability.degraded);
      },
    );
    try {
      final current = await _gateway.currentState();
      await _enqueue(
        () => _applyState(current, _clock.utcNow),
        operation: 'screen initialization',
      );
    } catch (error) {
      _logger.warning('Screen state initialization failed', error: error);
      _publishAvailability(CapabilityAvailability.degraded);
    }
  }

  Future<void> _applyState(ScreenState state, DateTime occurredAtUtc) async {
    if (state == ScreenState.unknown) {
      // An unavailable state must not be treated as "off": doing so would
      // silently truncate a real screen-on interval and undercount statistics.
      _publishAvailability(CapabilityAvailability.degraded);
      return;
    }
    final previous = _lastAppliedState;
    if (previous != null && _isLit(previous) == _isLit(state)) {
      _publishAvailability(CapabilityAvailability.available);
      return;
    }
    final changed = _isLit(state)
        ? await _repository.openScreenOnInterval(occurredAtUtc)
        : await _repository.closeScreenOnInterval(occurredAtUtc);
    _lastAppliedState = state;
    if (changed && !_changes.isClosed) _changes.add(null);
    _publishAvailability(CapabilityAvailability.available);
  }

  Future<void> _enqueue(
    Future<void> Function() action, {
    required String operation,
  }) {
    final work = _tail.then((_) => action());
    _tail = work.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        _logger.warning('$operation failed', error: error);
        _publishAvailability(CapabilityAvailability.degraded);
      },
    );
    return work;
  }

  void _publishAvailability(CapabilityAvailability availability) {
    _currentAvailability = availability;
    if (!_availability.isClosed) _availability.add(availability);
  }

  bool _isLit(ScreenState state) {
    return state == ScreenState.on || state == ScreenState.dimmed;
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _enqueue(
        () => _applyState(ScreenState.off, _clock.utcNow),
        operation: 'screen shutdown',
      );
    } catch (_) {
      // The queued operation has already logged and published degradation.
    }
    await _tail;
    await _changes.close();
    await _availability.close();
  }
}
