import 'dart:async';

import 'package:rest_eye/core/logging/app_logger.dart';
import 'package:rest_eye/features/settings/domain/settings_repository.dart';
import 'package:rest_eye/features/timer/application/ports/notification_gateway.dart';
import 'package:rest_eye/features/timer/application/timer_command_dispatcher.dart';
import 'package:rest_eye/features/timer/application/timer_cycle_config_factory.dart';
import 'package:rest_eye/features/timer/domain/timer_command.dart';
import 'package:rest_eye/features/timer/domain/timer_repository.dart';

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
  Future<void> _tail = Future.value();

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

  Future<void> handleAction(NotificationActionRequest action) async {
    final operation = _tail.then((_) => _dispatch(action));
    _tail = operation.then<void>((_) {}, onError: (_, _) {});
    await operation;
  }

  Future<void> _dispatch(NotificationActionRequest action) async {
    try {
      final command = await _commandFor(action);
      await _timerRepository.enqueueCommand(command);
      await _dispatcher.dispatch(command, fromInbox: true);
    } catch (error, stackTrace) {
      _logger.error(
        'Notification action handling failed',
        error: error,
        stackTrace: stackTrace,
      );
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
    };
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _tail;
  }
}
