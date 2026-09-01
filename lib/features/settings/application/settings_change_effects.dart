import 'package:rest_eye/features/settings/domain/app_settings.dart';

abstract interface class SettingsChangeEffects {
  Future<void> apply(AppSettings previous, AppSettings current);
}
