import 'package:rest_eye/features/statistics/domain/daily_statistics.dart';

abstract interface class StatisticsRepository {
  Future<DailyStatistics> loadForLocalDate(String localDateKey);
}
