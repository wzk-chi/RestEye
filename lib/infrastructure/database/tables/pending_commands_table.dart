import 'package:drift/drift.dart';

@DataClassName('PendingCommandRow')
@TableIndex(
  name: 'pending_commands_status_idx',
  columns: {#processedAtUtc, #staleAtUtc, #occurredAtUtc},
)
class PendingCommandsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get commandId => text().unique()();

  TextColumn get action => text()();

  TextColumn get cycleId => text().nullable()();

  TextColumn get expectedPhase => text().nullable()();

  IntColumn get expectedRevision => integer().nullable()();

  DateTimeColumn get occurredAtUtc => dateTime()();

  TextColumn get payloadJson => text()();

  DateTimeColumn get processedAtUtc => dateTime().nullable()();

  DateTimeColumn get staleAtUtc => dateTime().nullable()();
}
