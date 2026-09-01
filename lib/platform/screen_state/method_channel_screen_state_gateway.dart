import 'package:flutter/services.dart';
import 'package:rest_eye/core/clock/app_clock.dart';
import 'package:rest_eye/features/timer/application/ports/screen_state_gateway.dart';

final class MethodChannelScreenStateGateway implements ScreenStateGateway {
  MethodChannelScreenStateGateway(this._clock);

  static const _methodChannel = MethodChannel('dev.resteye/screen_state');
  static const _eventChannel = EventChannel('dev.resteye/screen_state/events');

  final AppClock _clock;
  late final Stream<ScreenStateChange> _changes = _eventChannel
      .receiveBroadcastStream()
      .map(
        (value) => ScreenStateChange(
          state: _parse(value is String ? value : null),
          occurredAtUtc: _clock.utcNow,
        ),
      );

  @override
  Future<ScreenState> currentState() async {
    try {
      final value = await _methodChannel.invokeMethod<String>(
        'getCurrentState',
      );
      return _parse(value);
    } on PlatformException {
      return ScreenState.unknown;
    } on MissingPluginException {
      return ScreenState.unknown;
    }
  }

  @override
  Stream<ScreenStateChange> get changes {
    return _changes;
  }

  ScreenState _parse(String? value) => switch (value) {
    'on' => ScreenState.on,
    'off' => ScreenState.off,
    'dimmed' => ScreenState.dimmed,
    _ => ScreenState.unknown,
  };
}
