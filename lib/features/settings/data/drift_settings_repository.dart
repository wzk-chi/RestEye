import 'package:drift/drift.dart';
import 'package:rest_eye/core/error/app_failure.dart';
import 'package:rest_eye/features/settings/domain/app_settings.dart';
import 'package:rest_eye/features/settings/domain/settings_repository.dart';
import 'package:rest_eye/features/timer/domain/timer_policy.dart';
import 'package:rest_eye/infrastructure/database/app_database.dart';

final class DriftSettingsRepository implements SettingsRepository {
  const DriftSettingsRepository(this._database);

  final AppDatabase _database;

  @override
  Future<AppSettings> load() async {
    try {
      final query = _database.select(_database.appSettingsTable)
        ..where((table) => table.id.equals(1));
      final row = await query.getSingleOrNull();
      if (row == null) {
        await save(AppSettings.defaults);
        return AppSettings.defaults;
      }
      final settings = AppSettings(
        workDuration: Duration(milliseconds: row.workDurationMs),
        restDuration: Duration(milliseconds: row.restDurationMs),
        reminderInterval: Duration(milliseconds: row.reminderIntervalMs),
        reminderTimeout: Duration(milliseconds: row.reminderTimeoutMs),
        missedWorkReminderInterval: Duration(
          milliseconds: row.missedWorkReminderIntervalMs,
        ),
        restTimeout: Duration(milliseconds: row.restTimeoutMs),
        androidVibrationEnabled: row.androidVibrationEnabled,
        workReminderEnabled: row.workReminderEnabled,
        restReminderEnabled: row.restReminderEnabled,
        missedRestReminderEnabled: row.missedRestReminderEnabled,
        missedWorkReminderEnabled: row.missedWorkReminderEnabled,
        localePreference: _localePreference(row.localeCode),
        themePreference: _themePreference(row.themeModeCode),
        pauseWhenLocked: row.pauseWhenLocked,
        fixedPortraitEnabled: row.fixedPortraitEnabled,
        minimizeToTrayOnClose: row.minimizeToTrayOnClose,
        timeoutBehavior: _timeoutBehavior(row.timeoutBehavior),
        restTimeoutBehavior: _timeoutBehavior(row.restTimeoutBehavior),
        restCompletionBehavior: _restCompletionBehavior(
          row.restCompletionBehavior,
        ),
      );
      final validationCode = settings.validate();
      if (validationCode != null) throw ValidationFailure(validationCode);
      return settings;
    } catch (error) {
      if (error is AppFailure) rethrow;
      throw PersistenceFailure('settings.load', cause: error);
    }
  }

  @override
  Future<void> save(AppSettings settings) async {
    final validationCode = settings.validate();
    if (validationCode != null) throw ValidationFailure(validationCode);
    try {
      await _database
          .into(_database.appSettingsTable)
          .insertOnConflictUpdate(
            AppSettingsTableCompanion(
              id: const Value(1),
              workDurationMs: Value(settings.workDuration.inMilliseconds),
              restDurationMs: Value(settings.restDuration.inMilliseconds),
              reminderIntervalMs: Value(
                settings.reminderInterval.inMilliseconds,
              ),
              reminderTimeoutMs: Value(settings.reminderTimeout.inMilliseconds),
              missedWorkReminderIntervalMs: Value(
                settings.missedWorkReminderInterval.inMilliseconds,
              ),
              restTimeoutMs: Value(settings.restTimeout.inMilliseconds),
              androidVibrationEnabled: Value(settings.androidVibrationEnabled),
              workReminderEnabled: Value(settings.workReminderEnabled),
              restReminderEnabled: Value(settings.restReminderEnabled),
              missedRestReminderEnabled: Value(
                settings.missedRestReminderEnabled,
              ),
              missedWorkReminderEnabled: Value(
                settings.missedWorkReminderEnabled,
              ),
              localeCode: Value(settings.localePreference.name),
              themeModeCode: Value(settings.themePreference.name),
              pauseWhenLocked: Value(settings.pauseWhenLocked),
              fixedPortraitEnabled: Value(settings.fixedPortraitEnabled),
              minimizeToTrayOnClose: Value(settings.minimizeToTrayOnClose),
              timeoutBehavior: Value(settings.timeoutBehavior.name),
              restTimeoutBehavior: Value(settings.restTimeoutBehavior.name),
              restCompletionBehavior: Value(
                settings.restCompletionBehavior.name,
              ),
            ),
          );
    } catch (error) {
      if (error is AppFailure) rethrow;
      throw PersistenceFailure('settings.save', cause: error);
    }
  }

  TimeoutBehavior _timeoutBehavior(String value) => switch (value) {
    'stopTimer' => TimeoutBehavior.stopTimer,
    _ => TimeoutBehavior.nextCycle,
  };

  RestCompletionBehavior _restCompletionBehavior(String value) =>
      switch (value) {
        'stopTimer' => RestCompletionBehavior.stopTimer,
        'continueRest' => RestCompletionBehavior.continueRest,
        _ => RestCompletionBehavior.startWork,
      };

  AppLocalePreference _localePreference(String value) => switch (value) {
    'zh' => AppLocalePreference.zh,
    'en' => AppLocalePreference.en,
    _ => AppLocalePreference.system,
  };

  AppThemePreference _themePreference(String value) => switch (value) {
    'light' => AppThemePreference.light,
    'dark' => AppThemePreference.dark,
    _ => AppThemePreference.system,
  };
}
