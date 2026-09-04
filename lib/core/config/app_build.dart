/// Compile-time build switches shared by domain defaults and platform setup.
///
/// Debug and release builds intentionally use different local database names
/// so test defaults can never overwrite a user's release settings.
abstract final class AppBuild {
  static const isDebugBuild =
      !bool.fromEnvironment('dart.vm.product') &&
      !bool.fromEnvironment('dart.vm.profile');

  static const databaseName = isDebugBuild ? 'rest_eye_debug' : 'rest_eye';

  static const defaultWorkDuration = isDebugBuild
      ? Duration(seconds: 5)
      : Duration(minutes: 20);
  static const defaultRestDuration = isDebugBuild
      ? Duration(seconds: 5)
      : Duration(seconds: 20);

  static const minWorkDuration = isDebugBuild
      ? Duration(seconds: 5)
      : Duration(minutes: 1);
  static const minRestDuration = isDebugBuild
      ? Duration(seconds: 5)
      : Duration(seconds: 10);

  static const debugDurationSliderMax = Duration(seconds: 60);
}
