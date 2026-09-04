import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/features/timer/domain/timer_policy.dart';

sealed class TimerCommand {
  const TimerCommand({
    required this.commandId,
    required this.occurredAtUtc,
    this.expectedCycleId,
    this.expectedPhase,
    this.expectedRevision,
  });

  final String commandId;
  final DateTime occurredAtUtc;
  final String? expectedCycleId;
  final TimerPhase? expectedPhase;
  final int? expectedRevision;
}

final class StartWorkCommand extends TimerCommand {
  const StartWorkCommand({
    required super.commandId,
    required super.occurredAtUtc,
    required this.cycleId,
    required this.cycleConfig,
    super.expectedCycleId,
    super.expectedPhase,
    super.expectedRevision,
  });

  final String cycleId;
  final TimerCycleConfig cycleConfig;
}

final class StartRestCommand extends TimerCommand {
  const StartRestCommand({
    required super.commandId,
    required super.occurredAtUtc,
    super.expectedCycleId,
    super.expectedPhase,
    super.expectedRevision,
  });
}

final class SuspendTimerCommand extends TimerCommand {
  const SuspendTimerCommand({
    required super.commandId,
    required super.occurredAtUtc,
    super.expectedCycleId,
    super.expectedPhase,
    super.expectedRevision,
  });
}

final class ResumeTimerCommand extends TimerCommand {
  const ResumeTimerCommand({
    required super.commandId,
    required super.occurredAtUtc,
    super.expectedCycleId,
    super.expectedPhase,
    super.expectedRevision,
  });
}

final class CompleteRestCommand extends TimerCommand {
  const CompleteRestCommand({
    required super.commandId,
    required super.occurredAtUtc,
    required this.nextCycleId,
    required this.nextCycleConfig,
    super.expectedCycleId,
    super.expectedPhase,
    super.expectedRevision,
  });

  final String nextCycleId;
  final TimerCycleConfig nextCycleConfig;
}

final class StopTimerCommand extends TimerCommand {
  const StopTimerCommand({
    required super.commandId,
    required super.occurredAtUtc,
    super.expectedCycleId,
    super.expectedPhase,
    super.expectedRevision,
  });
}

final class ReconcileTimerCommand extends TimerCommand {
  const ReconcileTimerCommand({
    required super.commandId,
    required super.occurredAtUtc,
    required this.nextCycleId,
    required this.nextCycleConfig,
    super.expectedCycleId,
    super.expectedPhase,
    super.expectedRevision,
  });

  final String nextCycleId;
  final TimerCycleConfig nextCycleConfig;
}
