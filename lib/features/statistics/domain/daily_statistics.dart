final class DailyStatistics {
  DailyStatistics({
    required this.localDateKey,
    required this.screenOnDuration,
    required this.restDuration,
    required this.restCount,
    this.timelineSegments = const [],
  }) : _workDuration = _calculateWorkDuration(timelineSegments);

  factory DailyStatistics.empty(String localDateKey) {
    return DailyStatistics(
      localDateKey: localDateKey,
      screenOnDuration: Duration.zero,
      restDuration: Duration.zero,
      restCount: 0,
    );
  }

  final String localDateKey;
  final Duration screenOnDuration;
  final Duration restDuration;
  final int restCount;
  final List<DailyTimelineSegment> timelineSegments;

  DailyStatistics copyWith({
    Duration? screenOnDuration,
    Duration? restDuration,
    int? restCount,
    List<DailyTimelineSegment>? timelineSegments,
  }) {
    return DailyStatistics(
      localDateKey: localDateKey,
      screenOnDuration: screenOnDuration ?? this.screenOnDuration,
      restDuration: restDuration ?? this.restDuration,
      restCount: restCount ?? this.restCount,
      timelineSegments: timelineSegments ?? this.timelineSegments,
    );
  }

  final Duration _workDuration;

  Duration get workDuration => _workDuration;

  static Duration _calculateWorkDuration(List<DailyTimelineSegment> segments) =>
      segments
          .where((segment) => segment.type == DailyTimelineSegmentType.work)
          .fold(Duration.zero, (total, segment) => total + segment.duration);
}

enum DailyTimelineSegmentType { work, rest }

final class DailyTimelineSegment {
  const DailyTimelineSegment({
    required this.type,
    required this.startedAtUtc,
    required this.endedAtUtc,
  });

  final DailyTimelineSegmentType type;
  final DateTime startedAtUtc;
  final DateTime endedAtUtc;

  Duration get duration => endedAtUtc.difference(startedAtUtc);
}
