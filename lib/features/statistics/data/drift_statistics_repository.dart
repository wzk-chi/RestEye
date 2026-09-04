import 'package:drift/drift.dart';
import 'package:rest_eye/core/error/app_failure.dart';
import 'package:rest_eye/features/statistics/domain/daily_statistics.dart';
import 'package:rest_eye/features/statistics/domain/statistics_repository.dart';
import 'package:rest_eye/infrastructure/database/app_database.dart';

final class DriftStatisticsRepository implements StatisticsRepository {
  const DriftStatisticsRepository(this._database);

  static const restCompletedType = 'restCompleted';
  static const workSuspendedType = 'workSuspended';

  final AppDatabase _database;

  @override
  Future<DailyStatistics> loadForLocalDate(String dateKey) async {
    try {
      final query = _database.select(_database.activityEventsTable)
        ..where(
          (table) =>
              table.localDateKey.equals(dateKey) &
              table.eventType.isIn(const [
                restCompletedType,
                workCompletedType,
                workSuspendedType,
              ]),
        );
      final rows = await query.get();
      var restMilliseconds = 0;
      var restCount = 0;
      final timelineSegments = <DailyTimelineSegment>[];
      for (final row in rows) {
        if (row.eventType == restCompletedType) {
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
      return DailyStatistics(
        localDateKey: dateKey,
        restDuration: Duration(milliseconds: restMilliseconds),
        restCount: restCount,
        timelineSegments: _sortedTimelineSegments(timelineSegments),
      );
    } catch (error) {
      throw PersistenceFailure('statistics.load', cause: error);
    }
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
