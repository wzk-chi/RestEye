import 'dart:ui' show AppExitResponse;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rest_eye/core/lifecycle/app_exit_gateway.dart';

final class FlutterAppExitGateway implements AppExitGateway {
  static const _androidChannel = MethodChannel('dev.resteye/app_exit');

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
    if (defaultTargetPlatform == TargetPlatform.android) {
      _androidChannel.setMethodCallHandler(_handleAndroidCall);
    }
  }

  Future<void> _handleAndroidCall(MethodCall call) async {
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
    if (defaultTargetPlatform == TargetPlatform.android) {
      _androidChannel.setMethodCallHandler(null);
    }
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
    _handler = null;
  }
}
