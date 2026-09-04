import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rest_eye/core/clock/app_clock.dart';

/// Cross-feature composition point for the app clock; bootstrap overrides it.
final appClockProvider = Provider<AppClock>((ref) {
  throw StateError('AppClock must be supplied during bootstrap');
});
