import 'package:drift/drift.dart';

@DataClassName('ScreenActivityStateRow')
class ScreenActivityStateTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  DateTimeColumn get startedAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
