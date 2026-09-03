import 'package:drift/drift.dart';

@DataClassName('AppSettingsRow')
class AppSettingsTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  IntColumn get workDurationMs => integer()();

  IntColumn get restDurationMs => integer()();

  IntColumn get reminderIntervalMs => integer()();

  IntColumn get reminderTimeoutMs => integer()();

  IntColumn get missedWorkReminderIntervalMs =>
      integer().withDefault(const Constant(180000))();

  IntColumn get restTimeoutMs =>
      integer().withDefault(const Constant(600000))();

  BoolColumn get androidVibrationEnabled => boolean()();

  BoolColumn get workReminderEnabled =>
      boolean().withDefault(const Constant(true))();

  BoolColumn get restReminderEnabled =>
      boolean().withDefault(const Constant(true))();

  BoolColumn get missedRestReminderEnabled =>
      boolean().withDefault(const Constant(true))();

  BoolColumn get missedWorkReminderEnabled =>
      boolean().withDefault(const Constant(true))();

  TextColumn get localeCode => text()();

  TextColumn get themeModeCode => text()();

  BoolColumn get pauseWhenLocked =>
      boolean().withDefault(const Constant(false))();

  BoolColumn get fixedPortraitEnabled =>
      boolean().withDefault(const Constant(true))();

  BoolColumn get minimizeToTrayOnClose =>
      boolean().withDefault(const Constant(true))();

  TextColumn get timeoutBehavior =>
      text().withDefault(const Constant('nextCycle'))();

  TextColumn get restTimeoutBehavior =>
      text().withDefault(const Constant('nextCycle'))();

  TextColumn get restCompletionBehavior =>
      text().withDefault(const Constant('startWork'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
