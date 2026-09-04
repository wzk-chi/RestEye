typedef AppExitHandler = Future<void> Function();

abstract interface class AppExitGateway {
  void start({required AppExitHandler onExitRequested});

  Future<void> dispose();
}
