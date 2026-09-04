import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rest_eye/core/clock/app_clock.dart';
import 'package:rest_eye/core/clock/local_date_key.dart';
import 'package:rest_eye/app/clock_provider.dart';
import 'package:rest_eye/features/statistics/application/statistics_dependencies.dart';
import 'package:rest_eye/features/statistics/domain/daily_statistics.dart';
import 'package:rest_eye/features/statistics/domain/statistics_repository.dart';
import 'package:rest_eye/features/timer/application/timer_dependencies.dart';
import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';

final class StatisticsViewState {
  const StatisticsViewState({required this.statistics, required this.date});

  final DailyStatistics statistics;
  final DateTime date;

  StatisticsViewState copyWith({DailyStatistics? statistics, DateTime? date}) {
    return StatisticsViewState(
      statistics: statistics ?? this.statistics,
      date: date ?? this.date,
    );
  }
}

final statisticsControllerProvider =
    AsyncNotifierProvider.autoDispose<
      StatisticsController,
      StatisticsViewState
    >(StatisticsController.new);

final class StatisticsController extends AsyncNotifier<StatisticsViewState> {
  Future<void>? _refreshOperation;
  var _refreshRequested = false;
  DateTime? _date;

  @override
  Future<StatisticsViewState> build() async {
    final dispatcher = ref.watch(timerCommandDispatcherProvider);
    final repository = ref.watch(statisticsRepositoryProvider);
    final clock = ref.watch(appClockProvider);
    final today = _dateOnly(clock.utcNow.toLocal());
    _date = today;
    var refreshRequested = false;
    void requestRefresh() {
      if (state.value == null) {
        refreshRequested = true;
        return;
      }
      unawaited(refresh());
    }

    final timerSubscription = dispatcher.snapshots.listen((_) {
      requestRefresh();
    });
    final minuteTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      // Live data only moves for the selected day while it is today; past
      // dates still refresh on timer snapshot changes via the subscription.
      final today = _dateOnly(clock.utcNow.toLocal());
      if (_date != today) return;
      requestRefresh();
    });
    ref.onDispose(() {
      minuteTimer.cancel();
      unawaited(timerSubscription.cancel());
    });

    StatisticsViewState initial;
    do {
      refreshRequested = false;
      initial = await _load(
        repository,
        clock,
        snapshot: dispatcher.current,
        date: _date!,
      );
    } while (refreshRequested);
    return initial;
  }

  Future<void> refresh() {
    if (!ref.mounted) return Future.value();
    _refreshRequested = true;
    final active = _refreshOperation;
    if (active != null) return active;
    final operation = _drainRefreshRequests();
    _refreshOperation = operation;
    return operation;
  }

  Future<void> _drainRefreshRequests() async {
    try {
      do {
        _refreshRequested = false;
        if (!ref.mounted) return;
        final refreshed = await AsyncValue.guard(
          () => _load(
            ref.read(statisticsRepositoryProvider),
            ref.read(appClockProvider),
            snapshot: ref.read(timerCommandDispatcherProvider).current,
            date: _date!,
          ),
        );
        if (ref.mounted) state = refreshed;
      } while (_refreshRequested && ref.mounted);
    } finally {
      _refreshOperation = null;
    }
  }

  Future<void> setDate(DateTime date) async {
    _date = _dateOnly(date);
    await refresh();
  }

  Future<StatisticsViewState> _load(
    StatisticsRepository repository,
    AppClock clock, {
    required TimerSnapshot snapshot,
    required DateTime date,
  }) async {
    final now = clock.utcNow;
    final stored = await repository.loadForLocalDate(localDateKey(date));
    final statistics = _includeActiveWork(stored, snapshot, now, date);
    return StatisticsViewState(statistics: statistics, date: date);
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DailyStatistics _includeActiveWork(
    DailyStatistics statistics,
    TimerSnapshot snapshot,
    DateTime nowUtc,
    DateTime date,
  ) {
    final startedAtUtc = switch (snapshot.phase) {
      TimerPhase.working
          when snapshot.executionStatus == ExecutionStatus.active =>
        snapshot.startedAtUtc.toUtc(),
      TimerPhase.awaitingRest => snapshot.startedAtUtc.toUtc(),
      _ => null,
    };
    if (startedAtUtc == null) return statistics;

    final deadline = snapshot.deadlineAtUtc?.toUtc();
    final now = nowUtc.toUtc();
    final end = deadline == null || now.isBefore(deadline) ? now : deadline;
    if (!end.isAfter(startedAtUtc)) return statistics;

    final dayStart = _dateOnly(date).toUtc();
    final dayEnd = DateTime(date.year, date.month, date.day + 1).toUtc();
    final visibleStart = startedAtUtc.isAfter(dayStart)
        ? startedAtUtc
        : dayStart;
    final visibleEnd = end.isBefore(dayEnd) ? end : dayEnd;
    if (!visibleEnd.isAfter(visibleStart)) return statistics;

    final segment = DailyTimelineSegment(
      type: DailyTimelineSegmentType.work,
      startedAtUtc: visibleStart,
      endedAtUtc: visibleEnd,
    );
    return statistics.copyWith(
      timelineSegments: List.unmodifiable([
        ...statistics.timelineSegments,
        segment,
      ]),
    );
  }
}
