import 'dart:ui' show AppExitResponse;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rest_eye/core/lifecycle/app_exit_gateway.dart';

final class FlutterAppExitGateway implements AppExitGateway {
  static const _appExitChannel = MethodChannel('dev.resteye/app_exit');

  AppLifecycleListener? _lifecycleListener;
  AppExitHandler? _handler;
  var _started = false;

  @override
  void start({required AppExitHandler onExitRequested}) {
    if (_started) return;
    _started = true;
    _handler = onExitRequested;
    _lifecycleListener = AppLifecycleListener(
      onExitRequested: () async {
        await _requestExit();
        return AppExitResponse.exit;
      },
    );
    // Windows and macOS hosts use this channel for window-close handshakes;
    // Android uses it for the root-back navigation handshake. The lifecycle
    // listener additionally covers OS-initiated exit requests (e.g. session
    // end on desktop).
    _appExitChannel.setMethodCallHandler(_handleAppExitCall);
  }

  Future<void> _handleAppExitCall(MethodCall call) async {
    if (call.method != 'prepareForExit') {
      throw MissingPluginException(
        'Unsupported app exit method: ${call.method}',
      );
    }
    await _requestExit();
  }

  Future<void> _requestExit() async {
    final handler = _handler;
    if (handler != null) await handler();
  }

  @override
  Future<void> dispose() async {
    if (!_started) return;
    _started = false;
    _appExitChannel.setMethodCallHandler(null);
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
    _handler = null;
  }
}
