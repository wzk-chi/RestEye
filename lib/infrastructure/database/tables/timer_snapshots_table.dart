import 'package:drift/drift.dart';

@DataClassName('TimerSnapshotRow')
class TimerSnapshotsTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  TextColumn get cycleId => text()();

  IntColumn get revision => integer()();

  TextColumn get phase => text()();

  TextColumn get executionStatus => text()();

  DateTimeColumn get startedAtUtc => dateTime()();

  DateTimeColumn get deadlineAtUtc => dateTime().nullable()();

  DateTimeColumn get nextReminderAtUtc => dateTime().nullable()();

  DateTimeColumn get lastHeartbeatAtUtc => dateTime().nullable()();

  IntColumn get workDurationMs => integer()();

  IntColumn get restDurationMs => integer()();

  IntColumn get reminderIntervalMs => integer()();

  IntColumn get reminderTimeoutMs => integer()();

  TextColumn get timeoutBehavior =>
      text().withDefault(const Constant('nextCycle'))();

  TextColumn get restCompletionBehavior =>
      text().withDefault(const Constant('startWork'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
