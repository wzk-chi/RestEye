import 'package:rest_eye/features/timer/domain/timer_event.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';

enum TimerTransitionOutcome { applied, ignored }

enum TimerIgnoredReason { staleCommand, invalidForCurrentPhase, noDeadline }

final class TimerTransition {
  const TimerTransition({
    required this.snapshot,
    required this.events,
    required this.outcome,
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
      ignoredReason: reason,
    );
  }

  final TimerSnapshot snapshot;
  final List<TimerEvent> events;
  final TimerTransitionOutcome outcome;
  final TimerIgnoredReason? ignoredReason;
}
