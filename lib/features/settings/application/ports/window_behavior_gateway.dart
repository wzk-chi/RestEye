enum WindowTrayMenuAction {
  startWork,
  resumeWork,
  startRest,
  skipRest,
  stopTimer,
}

final class WindowTrayMenuItem {
  const WindowTrayMenuItem({required this.action, required this.label});

  final WindowTrayMenuAction action;
  final String label;
}

abstract interface class WindowBehaviorGateway {
  Future<void> setMinimizeToTrayOnClose({required bool enabled});

  Future<void> setTrayMenu({
    required String appTitle,
    required String openApp,
    required String exitApp,
    required List<WindowTrayMenuItem> items,
  });

  Stream<WindowTrayMenuAction> get trayActions;
}
