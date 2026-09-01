import 'package:drift/drift.dart';
import 'package:rest_eye/core/error/app_failure.dart';
import 'package:rest_eye/features/statistics/domain/daily_statistics.dart';
import 'package:rest_eye/features/statistics/domain/statistics_repository.dart';
import 'package:rest_eye/infrastructure/database/app_database.dart';

final class DriftStatisticsRepository implements StatisticsRepository {
  const DriftStatisticsRepository(this._database);

  static const screenOnIntervalType = 'screenOnInterval';
  static const restCompletedType = 'restCompleted';
  static const workSuspendedType = 'workSuspended';

  final AppDatabase _database;

  @override
  Future<DailyStatistics> loadForLocalDate(
    String dateKey, {
    required DateTime nowUtc,
  }) async {
    try {
      final query = _database.select(_database.activityEventsTable)
        ..where(
          (table) =>
              table.localDateKey.equals(dateKey) &
              table.eventType.isIn(const [
                screenOnIntervalType,
                restCompletedType,
                workCompletedType,
                workSuspendedType,
              ]),
        );
      final rows = await query.get();
      final openQuery = _database.select(_database.screenActivityStateTable)
        ..where((table) => table.id.equals(1));
      final open = await openQuery.getSingleOrNull();
      var screenMilliseconds = 0;
      var restMilliseconds = 0;
      var restCount = 0;
      final timelineSegments = <DailyTimelineSegment>[];
      for (final row in rows) {
        if (row.eventType == screenOnIntervalType) {
          screenMilliseconds += row.durationMs;
        } else if (row.eventType == restCompletedType) {
          restMilliseconds += row.durationMs;
          restCount += row.countValue;
          _addTimelineSegment(
            timelineSegments,
            row,
            DailyTimelineSegmentType.rest,
          );
        } else if (row.eventType == workCompletedType ||
            row.eventType == workSuspendedType) {
          _addTimelineSegment(
            timelineSegments,
            row,
            DailyTimelineSegmentType.work,
          );
        }
      }
      if (open != null && localDateKey(nowUtc) == dateKey) {
        screenMilliseconds += _durationForDate(
          open.startedAtUtc.toUtc(),
          nowUtc.toUtc(),
          dateKey,
        ).inMilliseconds;
      }
      return DailyStatistics(
        localDateKey: dateKey,
        screenOnDuration: Duration(milliseconds: screenMilliseconds),
        restDuration: Duration(milliseconds: restMilliseconds),
        restCount: restCount,
        timelineSegments: _sortedTimelineSegments(timelineSegments),
      );
    } catch (error) {
      throw PersistenceFailure('statistics.load', cause: error);
    }
  }

  @override
  Future<bool> openScreenOnInterval(DateTime startedAtUtc) async {
    try {
      return await _database.transaction(() async {
        final query = _database.select(_database.screenActivityStateTable)
          ..where((table) => table.id.equals(1));
        if (await query.getSingleOrNull() != null) return false;
        await _database
            .into(_database.screenActivityStateTable)
            .insert(
              ScreenActivityStateTableCompanion.insert(
                startedAtUtc: startedAtUtc.toUtc(),
              ),
            );
        return true;
      });
    } catch (error) {
      throw PersistenceFailure('statistics.screen.open', cause: error);
    }
  }

  @override
  Future<bool> closeScreenOnInterval(DateTime endedAtUtc) async {
    try {
      return await _database.transaction(() async {
        final query = _database.select(_database.screenActivityStateTable)
          ..where((table) => table.id.equals(1));
        final open = await query.getSingleOrNull();
        if (open == null) return false;
        final start = open.startedAtUtc.toUtc();
        final end = endedAtUtc.toUtc();
        if (end.isAfter(start)) {
          await _insertScreenSegments(start, end);
        }
        await (_database.delete(
          _database.screenActivityStateTable,
        )..where((table) => table.id.equals(1))).go();
        return true;
      });
    } catch (error) {
      throw PersistenceFailure('statistics.screen.close', cause: error);
    }
  }

  Future<void> _insertScreenSegments(DateTime start, DateTime end) async {
    var segmentStartUtc = start;
    var index = 0;
    while (segmentStartUtc.isBefore(end)) {
      final localStart = segmentStartUtc.toLocal();
      final nextMidnightUtc = DateTime(
        localStart.year,
        localStart.month,
        localStart.day + 1,
      ).toUtc();
      final segmentEndUtc = nextMidnightUtc.isBefore(end)
          ? nextMidnightUtc
          : end;
      final segmentId =
          'screen-${start.microsecondsSinceEpoch}-${end.microsecondsSinceEpoch}-$index';
      await _database
          .into(_database.activityEventsTable)
          .insert(
            ActivityEventsTableCompanion(
              eventId: Value(segmentId),
              cycleId: const Value('screen'),
              eventType: const Value(screenOnIntervalType),
              occurredAtUtc: Value(segmentEndUtc),
              utcOffsetMinutes: Value(localStart.timeZoneOffset.inMinutes),
              localDateKey: Value(localDateKey(localStart)),
              durationMs: Value(
                segmentEndUtc.difference(segmentStartUtc).inMilliseconds,
              ),
              countValue: const Value(0),
            ),
            mode: InsertMode.insertOrIgnore,
          );
      segmentStartUtc = segmentEndUtc;
      index++;
    }
  }

  Duration _durationForDate(DateTime start, DateTime end, String dateKey) {
    if (!end.isAfter(start)) return Duration.zero;
    var result = Duration.zero;
    var segmentStartUtc = start;
    while (segmentStartUtc.isBefore(end)) {
      final localStart = segmentStartUtc.toLocal();
      final nextMidnightUtc = DateTime(
        localStart.year,
        localStart.month,
        localStart.day + 1,
      ).toUtc();
      final segmentEndUtc = nextMidnightUtc.isBefore(end)
          ? nextMidnightUtc
          : end;
      if (localDateKey(localStart) == dateKey) {
        result += segmentEndUtc.difference(segmentStartUtc);
      }
      segmentStartUtc = segmentEndUtc;
    }
    return result;
  }

  void _addTimelineSegment(
    List<DailyTimelineSegment> segments,
    ActivityEventRow row,
    DailyTimelineSegmentType type,
  ) {
    if (row.durationMs <= 0) return;
    final endedAtUtc = row.occurredAtUtc.toUtc();
    final startedAtUtc = endedAtUtc.subtract(
      Duration(milliseconds: row.durationMs),
    );
    segments.add(
      DailyTimelineSegment(
        type: type,
        startedAtUtc: startedAtUtc,
        endedAtUtc: endedAtUtc,
      ),
    );
  }

  List<DailyTimelineSegment> _sortedTimelineSegments(
    List<DailyTimelineSegment> segments,
  ) {
    segments.sort((a, b) => a.startedAtUtc.compareTo(b.startedAtUtc));
    return List.unmodifiable(segments);
  }

  static const workCompletedType = 'workCompleted';
}
