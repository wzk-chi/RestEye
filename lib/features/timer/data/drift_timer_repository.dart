import 'package:drift/drift.dart';
import 'package:rest_eye/core/clock/app_clock.dart';
import 'package:rest_eye/core/error/app_failure.dart';
import 'package:rest_eye/features/timer/data/timer_record_mapper.dart';
import 'package:rest_eye/features/timer/domain/timer_command.dart';
import 'package:rest_eye/features/timer/domain/timer_event.dart';
import 'package:rest_eye/features/timer/domain/timer_repository.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';
import 'package:rest_eye/infrastructure/database/app_database.dart';

final class DriftTimerRepository implements TimerRepository {
  const DriftTimerRepository(this._database, this._clock);

  final AppDatabase _database;
  final AppClock _clock;

  static const _commandRetention = Duration(days: 30);
  static const _maxPendingCommands = 10000;

  @override
  Future<TimerSnapshot> loadSnapshot() async {
    try {
      final query = _database.select(_database.timerSnapshotsTable)
        ..where((table) => table.id.equals(1));
      final row = await query.getSingleOrNull();
      return row == null
          ? TimerSnapshot.idle()
          : TimerRecordMapper.snapshotFromRow(row);
    } on FormatException catch (error) {
      throw PersistenceFailure('timer.snapshot.invalid', cause: error);
    } catch (error) {
      throw PersistenceFailure('timer.snapshot.load', cause: error);
    }
  }

  @override
  Future<void> commit({
    required int expectedRevision,
    required TimerSnapshot snapshot,
    required List<TimerEvent> events,
    String? processedCommandId,
    DateTime? processedAtUtc,
  }) async {
    try {
      await _database.transaction(() async {
        final query = _database.select(_database.timerSnapshotsTable)
          ..where((table) => table.id.equals(1));
        final current = await query.getSingleOrNull();
        final durableRevision = current?.revision ?? 0;
        if (durableRevision != expectedRevision) {
          throw const TimerCommitConflict();
        }

        await _database
            .into(_database.timerSnapshotsTable)
            .insertOnConflictUpdate(
              TimerRecordMapper.snapshotToCompanion(snapshot),
            );
        final eventRows = [
          for (final event in events)
            ...TimerRecordMapper.eventToCompanions(event),
        ];
        if (eventRows.isNotEmpty) {
          await _database.batch(
            (batch) => batch.insertAll(
              _database.activityEventsTable,
              eventRows,
              mode: InsertMode.insertOrIgnore,
            ),
          );
        }
        if (processedCommandId != null) {
          if (processedAtUtc == null) {
            throw ArgumentError(
              'processedAtUtc is required for inbox commands',
            );
          }
          await (_database.update(_database.pendingCommandsTable)
                ..where((table) => table.commandId.equals(processedCommandId)))
              .write(
                PendingCommandsTableCompanion(
                  processedAtUtc: Value(processedAtUtc.toUtc()),
                ),
              );
        }
      });
    } on TimerCommitConflict {
      rethrow;
    } catch (error) {
      throw PersistenceFailure('timer.commit', cause: error);
    }
  }

  @override
  Future<void> enqueueCommand(TimerCommand command) async {
    try {
      await _database
          .into(_database.pendingCommandsTable)
          .insert(
            PendingCommandsTableCompanion(
              commandId: Value(command.commandId),
              action: Value(TimerRecordMapper.commandKind(command)),
              cycleId: Value(command.expectedCycleId),
              expectedPhase: Value(command.expectedPhase?.name),
              expectedRevision: Value(command.expectedRevision),
              occurredAtUtc: Value(command.occurredAtUtc.toUtc()),
              payloadJson: Value(TimerRecordMapper.commandToJson(command)),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    } catch (error) {
      throw PersistenceFailure('timer.command.enqueue', cause: error);
    }
  }

  @override
  Future<List<TimerCommand>> loadPendingCommands() async {
    try {
      await _purgeTerminalCommands();
      final query = _database.select(_database.pendingCommandsTable)
        ..where(
          (table) => table.processedAtUtc.isNull() & table.staleAtUtc.isNull(),
        )
        ..orderBy([
          (table) => OrderingTerm.asc(table.occurredAtUtc),
          (table) => OrderingTerm.asc(table.id),
        ])
        ..limit(_maxPendingCommands);
      final rows = await query.get();
      return List.unmodifiable(rows.map(TimerRecordMapper.commandFromRow));
    } catch (error) {
      throw PersistenceFailure('timer.command.load', cause: error);
    }
  }

  Future<void> _purgeTerminalCommands() async {
    final cutoff = _clock.utcNow.subtract(_commandRetention);
    final table = _database.pendingCommandsTable;
    await (_database.delete(table)..where(
          (row) =>
              (row.processedAtUtc.isNotNull() &
                  row.processedAtUtc.isSmallerThanValue(cutoff)) |
              (row.staleAtUtc.isNotNull() &
                  row.staleAtUtc.isSmallerThanValue(cutoff)),
        ))
        .go();
  }

  @override
  Future<void> markCommandStale(String commandId, DateTime atUtc) async {
    try {
      await (_database.update(
        _database.pendingCommandsTable,
      )..where((table) => table.commandId.equals(commandId))).write(
        PendingCommandsTableCompanion(staleAtUtc: Value(atUtc.toUtc())),
      );
    } catch (error) {
      throw PersistenceFailure('timer.command.stale', cause: error);
    }
  }
}
