import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rest_eye/features/settings/application/settings_change_effects.dart';
import 'package:rest_eye/features/settings/application/ports/window_behavior_gateway.dart';
import 'package:rest_eye/features/settings/domain/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw StateError('SettingsRepository must be supplied during bootstrap');
});

final settingsChangeEffectsProvider = Provider<SettingsChangeEffects>((ref) {
  throw StateError('SettingsChangeEffects must be supplied during bootstrap');
});

final windowBehaviorGatewayProvider = Provider<WindowBehaviorGateway>((ref) {
  throw StateError('WindowBehaviorGateway must be supplied during bootstrap');
});
