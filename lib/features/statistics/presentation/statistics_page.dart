import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rest_eye/app/theme/rest_eye_spacing.dart';
import 'package:rest_eye/features/statistics/application/statistics_controller.dart';
import 'package:rest_eye/features/statistics/domain/daily_statistics.dart';
import 'package:rest_eye/l10n/generated/app_localizations.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final statistics = ref.watch(statisticsControllerProvider);
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.spacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatisticsHeader(
                title: strings.statisticsTitle,
                dateLabel: statistics.value == null
                    ? null
                    : _dateLabel(context, statistics.value!.date),
                onDateSelected: statistics.value == null
                    ? null
                    : () => _selectDate(context, ref, statistics.value!.date),
                onRefresh: () =>
                    ref.read(statisticsControllerProvider.notifier).refresh(),
                refreshTooltip: strings.actionRetry,
                showRefresh: statistics.hasError,
              ),
              SizedBox(height: context.spacing.lg),
              statistics.when(
                data: (data) =>
                    _ActivityTimelineCard(statistics: data.statistics),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, _) => Card(
                  child: Padding(
                    padding: EdgeInsets.all(context.spacing.lg),
                    child: Text(strings.statisticsUnavailable),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    WidgetRef ref,
    DateTime currentDate,
  ) async {
    final today = _dateOnly(DateTime.now());
    final strings = AppLocalizations.of(context);
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: today,
      initialDate: currentDate,
      helpText: strings.statisticsDatePickerTitle,
    );
    if (selected == null || !context.mounted) return;
    await ref.read(statisticsControllerProvider.notifier).setDate(selected);
  }

  String _dateLabel(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(date);
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

class _StatisticsHeader extends StatelessWidget {
  const _StatisticsHeader({
    required this.title,
    required this.dateLabel,
    required this.onDateSelected,
    required this.onRefresh,
    required this.refreshTooltip,
    required this.showRefresh,
  });

  final String title;
  final String? dateLabel;
  final VoidCallback? onDateSelected;
  final VoidCallback onRefresh;
  final String refreshTooltip;
  final bool showRefresh;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final titleWidget = Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        );
        final refreshButton = showRefresh
            ? IconButton(
                tooltip: refreshTooltip,
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
              )
            : null;
        if (dateLabel == null || onDateSelected == null) {
          return Row(
            children: [
              Expanded(child: titleWidget),
              ?refreshButton,
            ],
          );
        }

        final dateButton = OutlinedButton.icon(
          onPressed: onDateSelected,
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text(dateLabel!),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleWidget,
              SizedBox(height: context.spacing.sm),
              Row(
                children: [
                  Expanded(child: dateButton),
                  ?refreshButton,
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: titleWidget),
            SizedBox(width: context.spacing.lg),
            dateButton,
            ?refreshButton,
          ],
        );
      },
    );
  }
}

class _ActivityTimelineCard extends StatelessWidget {
  const _ActivityTimelineCard({required this.statistics});

  final DailyStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final palette = _TimelinePalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatisticsSurfaceCard(
          child: Padding(
            padding: EdgeInsets.all(context.spacing.lg),
            child: _TimelineMetrics(
              workDuration: statistics.workDuration,
              restDuration: statistics.restDuration,
              restCount: statistics.restCount,
              workColor: palette.work,
              restColor: palette.rest,
            ),
          ),
        ),
        SizedBox(height: context.spacing.md),
        _StatisticsSurfaceCard(
          child: Padding(
            padding: EdgeInsets.all(context.spacing.lg),
            child: _DailyTimelineContent(
              day: statistics,
              workColor: palette.work,
              restColor: palette.rest,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatisticsSurfaceCard extends StatelessWidget {
  const _StatisticsSurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: child,
    );
  }
}

class _TimelineMetrics extends StatelessWidget {
  const _TimelineMetrics({
    required this.workDuration,
    required this.restDuration,
    required this.restCount,
    required this.workColor,
    required this.restColor,
  });

  final Duration workDuration;
  final Duration restDuration;
  final int restCount;
  final Color workColor;
  final Color restColor;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final metrics = [
      _TimelineMetric(
        label: strings.statisticsTimelineWork,
        value: _durationText(strings, workDuration),
        accentColor: workColor,
        icon: Icons.work_outline,
      ),
      _TimelineMetric(
        label: strings.statisticsTimelineRest,
        value: _durationText(strings, restDuration),
        accentColor: restColor,
        icon: Icons.self_improvement_outlined,
      ),
      _TimelineMetric(
        label: strings.statisticsRestCount,
        value: strings.countTimes(restCount),
        accentColor: restColor,
        icon: Icons.check_circle_outline,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Wrap(
            spacing: context.spacing.lg,
            runSpacing: context.spacing.sm,
            children: metrics,
          );
        }
        return Row(
          children: [
            for (final metric in metrics)
              Expanded(
                child: Align(alignment: Alignment.centerLeft, child: metric),
              ),
          ],
        );
      },
    );
  }
}

class _TimelineMetric extends StatelessWidget {
  const _TimelineMetric({
    required this.label,
    required this.value,
    required this.accentColor,
    required this.icon,
  });

  final String label;
  final String value;
  final Color accentColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: accentColor, size: 20),
        SizedBox(width: context.spacing.sm),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.labelLarge),
            SizedBox(height: context.spacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}

String _durationText(AppLocalizations strings, Duration duration) {
  if (duration.inHours > 0) {
    return strings.durationHoursMinutes(
      duration.inHours,
      duration.inMinutes.remainder(60),
    );
  }
  if (duration.inMinutes > 0) {
    return strings.durationMinutes(duration.inMinutes);
  }
  return strings.durationSeconds(duration.inSeconds);
}

class _TimelineEmptyState extends StatelessWidget {
  const _TimelineEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.lg),
        child: Row(
          children: [
            Icon(Icons.insights_outlined, color: scheme.onSurfaceVariant),
            SizedBox(width: context.spacing.md),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _DailyTimelineContent extends StatelessWidget {
  const _DailyTimelineContent({
    required this.day,
    required this.workColor,
    required this.restColor,
  });

  final DailyStatistics day;
  final Color workColor;
  final Color restColor;

  @override
  Widget build(BuildContext context) {
    if (day.timelineSegments.isEmpty) {
      return _TimelineEmptyState(
        message: AppLocalizations.of(context).statisticsTimelineEmpty,
      );
    }

    return _DailyTimeline(day: day, workColor: workColor, restColor: restColor);
  }
}

class _DailyTimeline extends StatelessWidget {
  const _DailyTimeline({
    required this.day,
    required this.workColor,
    required this.restColor,
  });

  final DailyStatistics day;
  final Color workColor;
  final Color restColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DayTimeline(
          localDateKey: day.localDateKey,
          segments: day.timelineSegments,
          workColor: workColor,
          restColor: restColor,
        ),
      ],
    );
  }
}

class _DayTimeline extends StatelessWidget {
  const _DayTimeline({
    required this.localDateKey,
    required this.segments,
    required this.workColor,
    required this.restColor,
  });

  final String localDateKey;
  final List<DailyTimelineSegment> segments;
  final Color workColor;
  final Color restColor;

  @override
  Widget build(BuildContext context) {
    final day = DateTime.tryParse(localDateKey) ?? DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final timeFormat = DateFormat.Hm(locale);
    final strings = AppLocalizations.of(context);
    final segmentsByHour = _bucketSegments(day);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: Row(
            children: [
              for (var hour = 0; hour < 24; hour++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: _HourCell(
                      hour: hour,
                      day: day,
                      segments: segmentsByHour[hour],
                      timeFormat: timeFormat,
                      strings: strings,
                      workColor: workColor,
                      restColor: restColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: context.spacing.sm),
        SizedBox(
          height: 24,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(strings.statisticsTimelineStart),
              ),
              Align(
                alignment: const Alignment(-0.5, 0),
                child: Text(
                  timeFormat.format(DateTime(day.year, day.month, day.day, 6)),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  timeFormat.format(DateTime(day.year, day.month, day.day, 12)),
                ),
              ),
              Align(
                alignment: const Alignment(0.5, 0),
                child: Text(
                  timeFormat.format(DateTime(day.year, day.month, day.day, 18)),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(strings.statisticsTimelineEnd),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<List<DailyTimelineSegment>> _bucketSegments(DateTime day) {
    final buckets = List<List<DailyTimelineSegment>>.generate(
      24,
      (_) => <DailyTimelineSegment>[],
    );
    final dayStart = DateTime(day.year, day.month, day.day);
    for (final segment in segments) {
      final start = segment.startedAtUtc.toLocal();
      final end = segment.endedAtUtc.toLocal();
      if (!end.isAfter(dayStart)) continue;
      final endOfDay = dayStart.add(const Duration(days: 1));
      if (!start.isBefore(endOfDay)) continue;
      final visibleStart = start.isAfter(dayStart) ? start : dayStart;
      final visibleEnd = end.isBefore(endOfDay) ? end : endOfDay;
      if (!visibleEnd.isAfter(visibleStart)) continue;
      final firstHour = visibleStart
          .difference(dayStart)
          .inHours
          .clamp(0, 23)
          .toInt();
      final lastPoint = visibleEnd.subtract(const Duration(microseconds: 1));
      final lastHour = lastPoint
          .difference(dayStart)
          .inHours
          .clamp(0, 23)
          .toInt();
      for (var hour = firstHour; hour <= lastHour; hour++) {
        buckets[hour].add(segment);
      }
    }
    return buckets;
  }
}

class _HourCell extends StatelessWidget {
  const _HourCell({
    required this.hour,
    required this.day,
    required this.segments,
    required this.timeFormat,
    required this.strings,
    required this.workColor,
    required this.restColor,
  });

  final int hour;
  final DateTime day;
  final List<DailyTimelineSegment> segments;
  final DateFormat timeFormat;
  final AppLocalizations strings;
  final Color workColor;
  final Color restColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hourStart = DateTime(day.year, day.month, day.day, hour);
    final hourEnd = hourStart.add(const Duration(hours: 1));
    final hourDuration = hourEnd.difference(hourStart).inMilliseconds;
    final visibleSegments = <_VisibleTimelineSegment>[];
    for (final segment in segments) {
      final segmentStart = segment.startedAtUtc.toLocal();
      final segmentEnd = segment.endedAtUtc.toLocal();
      if (!segmentEnd.isAfter(hourStart) || !segmentStart.isBefore(hourEnd)) {
        continue;
      }
      final visibleStart = segmentStart.isAfter(hourStart)
          ? segmentStart
          : hourStart;
      final visibleEnd = segmentEnd.isBefore(hourEnd) ? segmentEnd : hourEnd;
      final duration = visibleEnd.difference(visibleStart).inMilliseconds;
      if (duration <= 0) continue;
      visibleSegments.add(
        _VisibleTimelineSegment(
          segment: segment,
          startFraction:
              visibleStart.difference(hourStart).inMilliseconds / hourDuration,
          widthFraction: duration / hourDuration,
          start: visibleStart,
          end: visibleEnd,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Tooltip(
          message: visibleSegments.isEmpty
              ? timeFormat.format(hourStart)
              : visibleSegments
                    .map(
                      (item) =>
                          '${_typeLabel(item.segment.type)} ${timeFormat.format(item.start)}–${timeFormat.format(item.end)}',
                    )
                    .join('\n'),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                ),
                for (final item in visibleSegments)
                  Positioned(
                    left: item.startFraction * constraints.maxWidth,
                    width: _paintedWidth(
                      item.widthFraction,
                      constraints.maxWidth,
                    ),
                    top: 0,
                    bottom: 0,
                    child: ColoredBox(
                      color: item.segment.type == DailyTimelineSegmentType.work
                          ? workColor
                          : restColor,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _typeLabel(DailyTimelineSegmentType type) => switch (type) {
    DailyTimelineSegmentType.work => strings.statisticsTimelineWork,
    DailyTimelineSegmentType.rest => strings.statisticsTimelineRest,
  };

  double _paintedWidth(double fraction, double availableWidth) {
    if (availableWidth <= 0) return 0;
    final width = fraction * availableWidth;
    if (availableWidth <= 2) return width;
    return width.clamp(2.0, availableWidth).toDouble();
  }
}

final class _TimelinePalette {
  const _TimelinePalette({required this.work, required this.rest});

  factory _TimelinePalette.of(BuildContext context) {
    return switch (Theme.of(context).brightness) {
      Brightness.light => const _TimelinePalette(
        work: Color(0xFF1557B0),
        rest: Color(0xFFB54708),
      ),
      Brightness.dark => const _TimelinePalette(
        work: Color(0xFF9CC8FF),
        rest: Color(0xFFFFB59B),
      ),
    };
  }

  final Color work;
  final Color rest;
}

final class _VisibleTimelineSegment {
  const _VisibleTimelineSegment({
    required this.segment,
    required this.startFraction,
    required this.widthFraction,
    required this.start,
    required this.end,
  });

  final DailyTimelineSegment segment;
  final double startFraction;
  final double widthFraction;
  final DateTime start;
  final DateTime end;
}
