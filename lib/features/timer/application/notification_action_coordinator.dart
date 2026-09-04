import 'dart:async';

import 'package:rest_eye/core/async/serial_operation_queue.dart';
import 'package:rest_eye/core/logging/app_logger.dart';
import 'package:rest_eye/features/settings/domain/settings_repository.dart';
import 'package:rest_eye/features/timer/application/ports/notification_gateway.dart';
import 'package:rest_eye/features/timer/application/timer_command_dispatcher.dart';
import 'package:rest_eye/features/timer/application/timer_cycle_config_factory.dart';
import 'package:rest_eye/features/timer/domain/timer_command.dart';
import 'package:rest_eye/features/timer/domain/timer_repository.dart';
import 'package:rest_eye/features/timer/domain/timer_transition.dart';

final class NotificationActionCoordinator {
  NotificationActionCoordinator(
    this._gateway,
    this._settingsRepository,
    this._timerRepository,
    this._dispatcher,
    this._logger,
  );

  final NotificationGateway _gateway;
  final SettingsRepository _settingsRepository;
  final TimerRepository _timerRepository;
  final TimerCommandDispatcher _dispatcher;
  final AppLogger _logger;
  StreamSubscription<NotificationActionRequest>? _subscription;
  final _queue = SerialOperationQueue();

  Future<void> initialize() async {
    start();
    final launchAction = await _gateway.takeLaunchAction();
    if (launchAction == null) return;
    await handleAction(launchAction);
  }

  void start() {
    if (_subscription != null) return;
    _subscription = _gateway.actions.listen(
      (action) => unawaited(handleAction(action)),
      onError: (Object error, StackTrace stackTrace) {
        _logger.warning('Notification action stream failed', error: error);
      },
    );
  }

  Future<bool> handleAction(NotificationActionRequest action) async {
    // Keep reconciliation from treating an action notification as missing
    // while the platform callback is still committing its timer command. The
    // reconcile that processes the command cancels the notification; the
    // release below only matters when the command itself failed, so
    // reconciliation can take the notification over again.
    _gateway.claimActionNotification(action.notificationId);
    try {
      return await _queue.run(() => _dispatch(action));
    } finally {
      _gateway.releaseActionNotification(action.notificationId);
    }
  }

  Future<bool> _dispatch(NotificationActionRequest action) async {
    try {
      final expiresAt = action.expiresAtUtc;
      if (expiresAt != null && action.occurredAtUtc.isAfter(expiresAt)) {
        // Do not enqueue an already-expired action. The next reconciliation
        // owns cancellation of the obsolete notification and no offline time
        // is fed into the timer reducer.
        return false;
      }
      final command = await _commandFor(action);
      await _timerRepository.enqueueCommand(command);
      final transition = await _dispatcher.dispatch(
        command,
        fromInbox: true,
        maxReconcileAtUtc: action.expiresAtUtc,
      );
      return transition.outcome == TimerTransitionOutcome.applied;
    } catch (error, stackTrace) {
      _logger.error(
        'Notification action handling failed',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<TimerCommand> _commandFor(NotificationActionRequest action) async {
    final settings = await _settingsRepository.load();
    return switch (action.type) {
      NotificationActionType.startRest => StartRestCommand(
        commandId: action.commandId,
        occurredAtUtc: action.occurredAtUtc,
        expectedCycleId: action.cycleId,
        expectedPhase: action.expectedPhase,
        expectedRevision: action.expectedRevision,
      ),
      NotificationActionType.skipRest => SkipRestCommand(
        commandId: action.commandId,
        occurredAtUtc: action.occurredAtUtc,
        expectedCycleId: action.cycleId,
        expectedPhase: action.expectedPhase,
        expectedRevision: action.expectedRevision,
        nextCycleId: _dispatcher.createId('cycle'),
        nextCycleConfig: timerCycleConfigFromSettings(settings),
      ),
      NotificationActionType.startWork => CompleteRestCommand(
        commandId: action.commandId,
        occurredAtUtc: action.occurredAtUtc,
        expectedCycleId: action.cycleId,
        expectedPhase: action.expectedPhase,
        expectedRevision: action.expectedRevision,
        nextCycleId: _dispatcher.createId('cycle'),
        nextCycleConfig: timerCycleConfigFromSettings(settings),
      ),
    };
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _queue.idle;
  }
}
