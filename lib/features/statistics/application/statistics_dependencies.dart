import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rest_eye/features/statistics/application/screen_activity_recorder.dart';
import 'package:rest_eye/features/statistics/domain/statistics_repository.dart';

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  throw StateError('StatisticsRepository must be supplied during bootstrap');
});

final screenActivityRecorderProvider = Provider<ScreenActivityRecorder>((ref) {
  throw StateError('ScreenActivityRecorder must be supplied during bootstrap');
});
