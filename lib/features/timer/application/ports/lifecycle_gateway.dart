enum AppLifecycleEvent { resumed, inactive, paused, detached, hidden }

abstract interface class LifecycleGateway {
  Stream<AppLifecycleEvent> get events;

  void start();

  Future<void> dispose();
}
