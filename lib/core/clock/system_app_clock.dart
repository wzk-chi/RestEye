import 'package:rest_eye/core/clock/app_clock.dart';

final class SystemAppClock implements AppClock {
  SystemAppClock() : _stopwatch = Stopwatch()..start();

  final Stopwatch _stopwatch;

  @override
  DateTime get utcNow => DateTime.now().toUtc();

  @override
  Duration get elapsed => _stopwatch.elapsed;
}
