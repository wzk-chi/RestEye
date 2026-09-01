import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rest_eye/features/settings/application/ports/window_behavior_gateway.dart';

final class FlutterWindowBehaviorGateway implements WindowBehaviorGateway {
  static const _channel = MethodChannel('dev.resteye/window_behavior');
  static const _eventsChannel = EventChannel(
    'dev.resteye/window_behavior/events',
  );

  bool get _isDesktop =>
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Future<void> setMinimizeToTrayOnClose({required bool enabled}) async {
    if (!_isDesktop) return;
    await _channel.invokeMethod<void>('setMinimizeToTrayOnClose', enabled);
  }

  @override
  Future<void> setTrayMenu({
    required String appTitle,
    required String openApp,
    required String exitApp,
    required List<WindowTrayMenuItem> items,
  }) async {
    if (!_isDesktop) return;
    await _channel.invokeMethod<void>('setTrayMenu', {
      'appTitle': appTitle,
      'openApp': openApp,
      'exitApp': exitApp,
      'items': [
        for (final item in items) {'id': item.action.name, 'label': item.label},
      ],
    });
  }

  @override
  Stream<WindowTrayMenuAction> get trayActions {
    if (!_isDesktop) return const Stream<WindowTrayMenuAction>.empty();
    return _eventsChannel
        .receiveBroadcastStream()
        .map(_decodeAction)
        .where((action) => action != null)
        .cast<WindowTrayMenuAction>();
  }

  WindowTrayMenuAction? _decodeAction(Object? value) {
    if (value is! String) return null;
    for (final action in WindowTrayMenuAction.values) {
      if (action.name == value) return action;
    }
    return null;
  }
}
