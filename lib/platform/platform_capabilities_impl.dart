import 'package:flutter/foundation.dart';
import 'package:rest_eye/features/timer/application/ports/platform_capabilities.dart';

PlatformCapabilities detectPlatformCapabilities() {
  final isAndroid = defaultTargetPlatform == TargetPlatform.android;
  final isDesktop =
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS;
  final supported = isAndroid || isDesktop;
  return PlatformCapabilities(
    notifications: supported
        ? CapabilityAvailability.available
        : CapabilityAvailability.unavailable,
    notificationActions: supported
        ? CapabilityAvailability.available
        : CapabilityAvailability.unavailable,
    screenState: supported
        ? CapabilityAvailability.available
        : CapabilityAvailability.unavailable,
    androidVibration: isAndroid
        ? CapabilityAvailability.available
        : CapabilityAvailability.unavailable,
    systemTray: isDesktop
        ? CapabilityAvailability.available
        : CapabilityAvailability.unavailable,
    windowControl: isDesktop
        ? CapabilityAvailability.available
        : CapabilityAvailability.unavailable,
  );
}
