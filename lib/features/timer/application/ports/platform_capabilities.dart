enum CapabilityAvailability { available, unavailable, degraded }

final class PlatformCapabilities {
  const PlatformCapabilities({
    required this.notifications,
    required this.notificationActions,
    required this.screenState,
    required this.androidVibration,
    required this.systemTray,
    required this.windowControl,
  });

  final CapabilityAvailability notifications;
  final CapabilityAvailability notificationActions;
  final CapabilityAvailability screenState;
  final CapabilityAvailability androidVibration;
  final CapabilityAvailability systemTray;
  final CapabilityAvailability windowControl;

  PlatformCapabilities copyWith({
    CapabilityAvailability? notifications,
    CapabilityAvailability? notificationActions,
    CapabilityAvailability? screenState,
    CapabilityAvailability? androidVibration,
    CapabilityAvailability? systemTray,
    CapabilityAvailability? windowControl,
  }) {
    return PlatformCapabilities(
      notifications: notifications ?? this.notifications,
      notificationActions: notificationActions ?? this.notificationActions,
      screenState: screenState ?? this.screenState,
      androidVibration: androidVibration ?? this.androidVibration,
      systemTray: systemTray ?? this.systemTray,
      windowControl: windowControl ?? this.windowControl,
    );
  }
}
