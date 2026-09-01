import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rest_eye/features/settings/application/ports/orientation_gateway.dart';

final class FlutterOrientationGateway implements OrientationGateway {
  @override
  Future<void> setFixedPortrait({required bool enabled}) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await SystemChrome.setPreferredOrientations(
      enabled
          ? const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
          : const [],
    );
  }
}
