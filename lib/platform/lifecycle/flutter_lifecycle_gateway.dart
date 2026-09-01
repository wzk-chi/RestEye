import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rest_eye/features/timer/application/ports/lifecycle_gateway.dart';

final class FlutterLifecycleGateway
    with WidgetsBindingObserver
    implements LifecycleGateway {
  final _events = StreamController<AppLifecycleEvent>.broadcast();
  var _started = false;

  @override
  Stream<AppLifecycleEvent> get events => _events.stream;

  @override
  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _events.add(switch (state) {
      AppLifecycleState.resumed => AppLifecycleEvent.resumed,
      AppLifecycleState.inactive => AppLifecycleEvent.inactive,
      AppLifecycleState.paused => AppLifecycleEvent.paused,
      AppLifecycleState.detached => AppLifecycleEvent.detached,
      AppLifecycleState.hidden => AppLifecycleEvent.hidden,
    });
  }

  @override
  Future<void> dispose() async {
    if (_started) WidgetsBinding.instance.removeObserver(this);
    _started = false;
    await _events.close();
  }
}
