import 'package:rest_eye/features/timer/domain/timer_event.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';

enum TimerTransitionOutcome { applied, ignored }

enum TimerIgnoredReason { staleCommand, invalidForCurrentPhase, noDeadline }

enum NotificationIntent { none, reconcile }

final class TimerTransition {
  const TimerTransition({
    required this.snapshot,
    required this.events,
    required this.outcome,
    required this.notificationIntent,
    this.ignoredReason,
  });

  factory TimerTransition.ignored(
    TimerSnapshot snapshot,
    TimerIgnoredReason reason,
  ) {
    return TimerTransition(
      snapshot: snapshot,
      events: const [],
      outcome: TimerTransitionOutcome.ignored,
      notificationIntent: NotificationIntent.none,
      ignoredReason: reason,
    );
  }

  final TimerSnapshot snapshot;
  final List<TimerEvent> events;
  final TimerTransitionOutcome outcome;
  final NotificationIntent notificationIntent;
  final TimerIgnoredReason? ignoredReason;
}
