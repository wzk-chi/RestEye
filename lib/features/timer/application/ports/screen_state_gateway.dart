enum ScreenState { on, off, dimmed, unknown }

final class ScreenStateChange {
  const ScreenStateChange({required this.state, required this.occurredAtUtc});

  final ScreenState state;
  final DateTime occurredAtUtc;
}

abstract interface class ScreenStateGateway {
  Future<ScreenState> currentState();

  Stream<ScreenStateChange> get changes;
}
