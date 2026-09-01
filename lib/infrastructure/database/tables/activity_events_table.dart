import 'package:drift/drift.dart';

@DataClassName('ActivityEventRow')
@TableIndex(
  name: 'activity_events_local_date_key_idx',
  columns: {#localDateKey},
)
@TableIndex(name: 'activity_events_occurred_at_idx', columns: {#occurredAtUtc})
class ActivityEventsTable extends Table {
  TextColumn get eventId => text()();

  TextColumn get cycleId => text()();

  TextColumn get eventType => text()();

  DateTimeColumn get occurredAtUtc => dateTime()();

  IntColumn get utcOffsetMinutes => integer()();

  TextColumn get localDateKey => text()();

  IntColumn get durationMs => integer().withDefault(const Constant(0))();

  IntColumn get countValue => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {eventId};
}
