import 'package:rest_eye/features/statistics/domain/daily_statistics.dart';

abstract interface class StatisticsRepository {
  Future<DailyStatistics> loadForLocalDate(
    String localDateKey, {
    required DateTime nowUtc,
  });

  Future<bool> openScreenOnInterval(DateTime startedAtUtc);

  Future<bool> closeScreenOnInterval(DateTime endedAtUtc);
}

String localDateKey(DateTime dateTime) {
  final local = dateTime.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}
