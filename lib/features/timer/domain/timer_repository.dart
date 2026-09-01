import 'package:rest_eye/features/timer/domain/timer_command.dart';
import 'package:rest_eye/features/timer/domain/timer_event.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';

abstract interface class TimerRepository {
  Future<TimerSnapshot> loadSnapshot();

  Future<void> commit({
    required int expectedRevision,
    required TimerSnapshot snapshot,
    required List<TimerEvent> events,
    String? processedCommandId,
    DateTime? processedAtUtc,
  });

  Future<void> enqueueCommand(TimerCommand command);

  Future<List<TimerCommand>> loadPendingCommands();

  Future<void> markCommandStale(String commandId, DateTime atUtc);
}

final class TimerCommitConflict implements Exception {
  const TimerCommitConflict();
}
