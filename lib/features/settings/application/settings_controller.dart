import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rest_eye/core/error/app_failure.dart';
import 'package:rest_eye/features/settings/application/settings_dependencies.dart';
import 'package:rest_eye/features/settings/domain/app_settings.dart';
import 'package:rest_eye/features/timer/domain/timer_policy.dart';

final class SettingsViewState {
  const SettingsViewState({
    required this.saved,
    required this.draft,
    this.saving = false,
    this.validationError,
    this.saveFailureCode,
  });

  final AppSettings saved;
  final AppSettings draft;
  final bool saving;
  final ValidationFailureCode? validationError;
  final String? saveFailureCode;

  bool get hasChanges => saved != draft;

  SettingsViewState copyWith({
    AppSettings? saved,
    AppSettings? draft,
    bool? saving,
    ValidationFailureCode? validationError,
    bool clearValidationError = false,
    String? saveFailureCode,
    bool clearSaveFailure = false,
  }) {
    return SettingsViewState(
      saved: saved ?? this.saved,
      draft: draft ?? this.draft,
      saving: saving ?? this.saving,
      validationError: clearValidationError
          ? null
          : validationError ?? this.validationError,
      saveFailureCode: clearSaveFailure
          ? null
          : saveFailureCode ?? this.saveFailureCode,
    );
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, SettingsViewState>(
      SettingsController.new,
    );

final class SettingsController extends AsyncNotifier<SettingsViewState> {
  static const _autoSaveDelay = Duration(milliseconds: 400);

  Timer? _autoSaveTimer;
  Future<void>? _saveOperation;
  var _saveAgain = false;

  @override
  Future<SettingsViewState> build() async {
    ref.onDispose(() => _autoSaveTimer?.cancel());
    final repository = ref.watch(settingsRepositoryProvider);
    final settings = await repository.load();
    return SettingsViewState(saved: settings, draft: settings);
  }

  void setWorkDuration(Duration value) {
    _update((settings) => settings.copyWith(workDuration: value));
  }

  void setRestDuration(Duration value) {
    _update((settings) => settings.copyWith(restDuration: value));
  }

  void setReminderInterval(Duration value) {
    _update((settings) => settings.copyWith(reminderInterval: value));
  }

  void setReminderTimeout(Duration value) {
    _update((settings) => settings.copyWith(reminderTimeout: value));
  }

  void setMissedWorkReminderInterval(Duration value) {
    _update((settings) => settings.copyWith(missedWorkReminderInterval: value));
  }

  void setRestTimeout(Duration value) {
    _update((settings) => settings.copyWith(restTimeout: value));
  }

  void setTimeoutBehavior(TimeoutBehavior value) {
    _update((settings) => settings.copyWith(timeoutBehavior: value));
  }

  void setRestTimeoutBehavior(TimeoutBehavior value) {
    _update((settings) => settings.copyWith(restTimeoutBehavior: value));
  }

  void setRestCompletionBehavior(RestCompletionBehavior value) {
    _update((settings) => settings.copyWith(restCompletionBehavior: value));
  }

  void setAndroidVibrationEnabled(bool value) {
    _update((settings) => settings.copyWith(androidVibrationEnabled: value));
  }

  void setWorkReminderEnabled(bool value) {
    _update((settings) => settings.copyWith(workReminderEnabled: value));
  }

  void setRestReminderEnabled(bool value) {
    _update((settings) => settings.copyWith(restReminderEnabled: value));
  }

  void setMissedRestReminderEnabled(bool value) {
    _update((settings) => settings.copyWith(missedRestReminderEnabled: value));
  }

  void setMissedWorkReminderEnabled(bool value) {
    _update((settings) => settings.copyWith(missedWorkReminderEnabled: value));
  }

  void setPauseWhenLocked(bool value) {
    _update((settings) => settings.copyWith(pauseWhenLocked: value));
  }

  void setFixedPortraitEnabled(bool value) {
    _update((settings) => settings.copyWith(fixedPortraitEnabled: value));
  }

  void setMinimizeToTrayOnClose(bool value) {
    _update((settings) => settings.copyWith(minimizeToTrayOnClose: value));
  }

  void setLocalePreference(AppLocalePreference value) {
    _update((settings) => settings.copyWith(localePreference: value));
  }

  void setThemePreference(AppThemePreference value) {
    _update((settings) => settings.copyWith(themePreference: value));
  }

  Future<void> retrySave() async {
    _autoSaveTimer?.cancel();
    await _persistLatest(force: true);
  }

  void _update(AppSettings Function(AppSettings current) update) {
    final current = state.value;
    if (current == null) return;
    final draft = update(current.draft);
    if (draft == current.draft) return;
    _autoSaveTimer?.cancel();
    final validationError = draft.validate();
    state = AsyncData(
      current.copyWith(
        draft: draft,
        validationError: validationError,
        clearValidationError: validationError == null,
        clearSaveFailure: true,
      ),
    );
    if (validationError == null) {
      _autoSaveTimer = Timer(_autoSaveDelay, () {
        _autoSaveTimer = null;
        unawaited(_persistLatest());
      });
    }
  }

  Future<void> _persistLatest({bool force = false}) async {
    final activeOperation = _saveOperation;
    if (activeOperation != null) {
      _saveAgain = true;
      await activeOperation;
      return;
    }
    final operation = _saveLatest(force: force);
    _saveOperation = operation;
    try {
      await operation;
    } finally {
      _saveOperation = null;
      if (_saveAgain && ref.mounted) {
        _saveAgain = false;
        unawaited(_persistLatest());
      }
    }
  }

  Future<void> _saveLatest({required bool force}) async {
    final current = state.value;
    if (current == null || current.validationError != null) return;
    if (!force && !current.hasChanges) return;
    final target = current.draft;
    final previous = current.saved;
    state = AsyncData(
      current.copyWith(
        saving: true,
        clearValidationError: true,
        clearSaveFailure: true,
      ),
    );
    try {
      await ref.read(settingsRepositoryProvider).save(target);
      if (!ref.mounted) return;
      // Keep `saved` at the last fully applied value until every runtime
      // effect succeeds.  Persisting first is intentional (the repository is
      // the source of truth), but advancing the UI's saved marker here would
      // make a failed effect impossible to retry: the next attempt would see
      // `previous == target` and skip the duration/notification diff.
      await ref.read(settingsChangeEffectsProvider).apply(previous, target);
      if (!ref.mounted) return;
      final latest = state.value;
      if (latest == null) return;
      final hasPendingValidChanges =
          latest.draft != target && latest.validationError == null;
      state = AsyncData(
        latest.copyWith(saved: target, saving: false, clearSaveFailure: true),
      );
      if (hasPendingValidChanges) {
        _autoSaveTimer?.cancel();
        _saveAgain = true;
      }
    } on ValidationFailure catch (failure) {
      if (!ref.mounted) return;
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(saving: false, validationError: failure.validationCode),
      );
    } on AppFailure catch (failure) {
      if (!ref.mounted) return;
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(saving: false, saveFailureCode: failure.code),
      );
    } catch (_) {
      if (!ref.mounted) return;
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(saving: false, saveFailureCode: 'unexpected'),
      );
    }
  }
}
