import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rest_eye/app/theme/rest_eye_spacing.dart';
import 'package:rest_eye/core/build/app_build.dart';
import 'package:rest_eye/features/settings/application/settings_controller.dart';
import 'package:rest_eye/features/timer/application/ports/notification_gateway.dart';
import 'package:rest_eye/features/timer/application/ports/platform_capabilities.dart';
import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/features/timer/domain/timer_policy.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';
import 'package:rest_eye/features/timer/presentation/timer_controller.dart';
import 'package:rest_eye/features/timer/presentation/widgets/countdown_card.dart';
import 'package:rest_eye/l10n/generated/app_localizations.dart';

class TimerPage extends ConsumerWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageState = ref.watch(
      timerControllerProvider.select(
        (state) => (
          snapshot: state.snapshot,
          notificationPermission: state.notificationPermission,
          notificationCapability: state.notificationCapability,
          busy: state.busy,
          failureCode: state.failureCode,
        ),
      ),
    );
    final savedSettings = ref.watch(
      settingsControllerProvider.select((state) => state.value?.saved),
    );
    final snapshot = pageState.snapshot;
    final controller = ref.read(timerControllerProvider.notifier);
    final strings = AppLocalizations.of(context);
    final showSavedDurations = snapshot.phase == TimerPhase.idle;
    final workDuration = showSavedDurations
        ? savedSettings?.workDuration ?? snapshot.cycleConfig.workDuration
        : snapshot.cycleConfig.workDuration;
    final restDuration = showSavedDurations
        ? savedSettings?.restDuration ?? snapshot.cycleConfig.restDuration
        : snapshot.cycleConfig.restDuration;

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.spacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.appTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: context.spacing.xs),
              Text(
                strings.appTagline,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: context.spacing.lg),
              if (pageState.notificationPermission ==
                  NotificationPermissionStatus.denied)
                _NotificationBanner(
                  title: strings.notificationPermissionTitle,
                  message: strings.notificationPermissionMessage,
                  actionLabel: strings.actionRequestPermission,
                  onPressed: controller.requestNotificationPermission,
                )
              else if (pageState.notificationCapability ==
                  CapabilityAvailability.degraded)
                _NotificationBanner(
                  title: strings.notificationPermissionTitle,
                  message: strings.notificationDegraded,
                ),
              if (pageState.notificationPermission ==
                      NotificationPermissionStatus.denied ||
                  pageState.notificationCapability ==
                      CapabilityAvailability.degraded)
                SizedBox(height: context.spacing.md),
              const _LiveCountdown(),
              SizedBox(height: context.spacing.md),
              _CycleSummary(
                workDuration: _durationText(strings, workDuration),
                restDuration: _durationText(strings, restDuration),
                onEditWorkDuration: () => _showQuickDurationDialog(
                  context,
                  ref,
                  _QuickDurationKind.work,
                ),
                onEditRestDuration: () => _showQuickDurationDialog(
                  context,
                  ref,
                  _QuickDurationKind.rest,
                ),
              ),
              SizedBox(height: context.spacing.lg),
              _TimerActions(
                phase: snapshot.phase,
                executionStatus: snapshot.executionStatus,
                busy: pageState.busy,
                onStartWork: controller.startWork,
                onResumeWork: controller.resumeWork,
                onStartRest: controller.startRest,
                onSkipRest: controller.skipRest,
                onStartWorkAfterRest: controller.startWorkAfterRest,
                onStop: controller.stop,
              ),
              if (pageState.failureCode != null) ...[
                SizedBox(height: context.spacing.md),
                Text(
                  strings.commandFailed,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _phaseTitle(
    AppLocalizations strings,
    TimerPhase phase,
    ExecutionStatus executionStatus,
  ) {
    if (executionStatus == ExecutionStatus.suspended) {
      return strings.timerPhaseSuspended;
    }
    return switch (phase) {
      TimerPhase.idle => strings.timerPhaseIdle,
      TimerPhase.working => strings.timerPhaseWorking,
      TimerPhase.awaitingRest => strings.timerPhaseAwaitingRest,
      TimerPhase.resting => strings.timerPhaseResting,
      TimerPhase.awaitingWork => strings.timerPhaseAwaitingWork,
    };
  }

  static String _phaseMessage(
    AppLocalizations strings,
    TimerPhase phase,
    ExecutionStatus executionStatus,
  ) {
    if (executionStatus == ExecutionStatus.suspended) {
      return strings.timerSuspendedMessage;
    }
    return switch (phase) {
      TimerPhase.idle => strings.timerIdleMessage,
      TimerPhase.working => strings.timerWorkingMessage,
      TimerPhase.awaitingRest => strings.timerAwaitingRestMessage,
      TimerPhase.resting => strings.timerRestingMessage,
      TimerPhase.awaitingWork => strings.timerAwaitingWorkMessage,
    };
  }

  static Duration _elapsedDuration(
    TimerSnapshot snapshot,
    Duration remaining,
    Duration displayDuration,
  ) {
    if (snapshot.phase == TimerPhase.awaitingRest ||
        snapshot.phase == TimerPhase.awaitingWork) {
      return displayDuration.isNegative ? Duration.zero : displayDuration;
    }
    if (snapshot.phase == TimerPhase.resting &&
        snapshot.cycleConfig.restCompletionBehavior ==
            RestCompletionBehavior.continueRest &&
        (snapshot.deadlineAtUtc == null ||
            displayDuration > snapshot.cycleConfig.restDuration)) {
      return displayDuration.isNegative ? Duration.zero : displayDuration;
    }
    final totalDuration = switch (snapshot.phase) {
      TimerPhase.idle => Duration.zero,
      TimerPhase.working => snapshot.cycleConfig.workDuration,
      TimerPhase.resting => snapshot.cycleConfig.restDuration,
      TimerPhase.awaitingRest => Duration.zero,
      TimerPhase.awaitingWork => Duration.zero,
    };
    final elapsed = totalDuration - remaining;
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  static Color _phaseColor(
    BuildContext context,
    TimerPhase phase,
    ExecutionStatus executionStatus,
  ) {
    final scheme = Theme.of(context).colorScheme;
    if (executionStatus == ExecutionStatus.suspended ||
        phase == TimerPhase.idle) {
      return scheme.outline;
    }
    return switch (phase) {
      TimerPhase.working => scheme.primary,
      TimerPhase.awaitingRest => scheme.error,
      TimerPhase.resting => scheme.tertiary,
      TimerPhase.awaitingWork => scheme.tertiary,
      TimerPhase.idle => scheme.outline,
    };
  }

  static String _formatElapsed(Duration duration) {
    final totalSeconds = duration.isNegative ? 0 : duration.inSeconds;
    final hours = totalSeconds ~/ Duration.secondsPerHour;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static String _durationText(AppLocalizations strings, Duration duration) {
    if (duration.inSeconds < 60) {
      return strings.durationSeconds(duration.inSeconds);
    }
    return strings.durationMinutes(duration.inMinutes);
  }

  Future<void> _showQuickDurationDialog(
    BuildContext context,
    WidgetRef ref,
    _QuickDurationKind kind,
  ) async {
    final settings = ref.read(settingsControllerProvider).value?.draft;
    if (settings == null) return;
    final selected = await showDialog<Duration>(
      context: context,
      builder: (_) => _QuickDurationDialog(
        kind: kind,
        initialValue: kind == _QuickDurationKind.work
            ? settings.workDuration
            : settings.restDuration,
      ),
    );
    if (selected == null || !context.mounted) return;
    final controller = ref.read(settingsControllerProvider.notifier);
    switch (kind) {
      case _QuickDurationKind.work:
        controller.setWorkDuration(selected);
      case _QuickDurationKind.rest:
        controller.setRestDuration(selected);
    }
  }
}

class _LiveCountdown extends ConsumerWidget {
  const _LiveCountdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(
      timerControllerProvider.select(
        (state) => (
          snapshot: state.snapshot,
          remaining: state.remaining,
          displayDuration: state.displayDuration,
          progress: state.progress,
        ),
      ),
    );
    final strings = AppLocalizations.of(context);
    final snapshot = live.snapshot;
    final phase = TimerPage._phaseTitle(
      strings,
      snapshot.phase,
      snapshot.executionStatus,
    );
    final elapsed = TimerPage._elapsedDuration(
      snapshot,
      live.remaining,
      live.displayDuration,
    );
    final isResting =
        snapshot.phase == TimerPhase.resting ||
        snapshot.phase == TimerPhase.awaitingWork;
    final time = TimerPage._formatElapsed(elapsed);
    return CountdownCard(
      phase: phase,
      message: TimerPage._phaseMessage(
        strings,
        snapshot.phase,
        snapshot.executionStatus,
      ),
      time: time,
      elapsedLabel: isResting
          ? strings.timerElapsedRest
          : strings.timerElapsedWork,
      progress: live.progress,
      progressSemantics: strings.accessibilityTimerProgress(
        (live.progress * 100).round(),
      ),
      timeSemantics: isResting
          ? strings.timerElapsedRestSemantics(phase, time)
          : strings.timerElapsedWorkSemantics(phase, time),
      accentColor: TimerPage._phaseColor(
        context,
        snapshot.phase,
        snapshot.executionStatus,
      ),
    );
  }
}

class _CycleSummary extends StatelessWidget {
  const _CycleSummary({
    required this.workDuration,
    required this.restDuration,
    required this.onEditWorkDuration,
    required this.onEditRestDuration,
  });

  final String workDuration;
  final String restDuration;
  final VoidCallback onEditWorkDuration;
  final VoidCallback onEditRestDuration;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: Icons.work_outline,
              text: strings.timerWorkDuration(workDuration),
              tooltip: strings.settingsEditValue(strings.settingsWorkDuration),
              onTap: onEditWorkDuration,
            ),
          ),
          Container(
            width: 1,
            height: context.spacing.xxl,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.self_improvement_outlined,
              text: strings.timerRestDuration(restDuration),
              tooltip: strings.settingsEditValue(strings.settingsRestDuration),
              onTap: onEditRestDuration,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.text,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(context.spacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              SizedBox(width: context.spacing.sm),
              Flexible(child: Text(text, textAlign: TextAlign.center)),
              SizedBox(width: context.spacing.xs),
              const Icon(Icons.edit_outlined, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

enum _QuickDurationKind { work, rest }

class _QuickDurationDialog extends StatefulWidget {
  const _QuickDurationDialog({required this.kind, required this.initialValue});

  final _QuickDurationKind kind;
  final Duration initialValue;

  @override
  State<_QuickDurationDialog> createState() => _QuickDurationDialogState();
}

class _QuickDurationDialogState extends State<_QuickDurationDialog> {
  late int _value;

  bool get _isWork => widget.kind == _QuickDurationKind.work;

  @override
  void initState() {
    super.initState();
    final isDebugBuild = AppBuild.isDebugBuild;
    _value = _isWork
        ? isDebugBuild
              ? widget.initialValue.inSeconds
              : widget.initialValue.inMinutes
        : widget.initialValue.inSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final isDebugBuild = AppBuild.isDebugBuild;
    final valueLabel = _isWork && !isDebugBuild
        ? strings.settingsMinutesValue(_value)
        : strings.settingsSecondsValue(_value);
    return AlertDialog(
      title: Text(
        _isWork
            ? strings.timerQuickWorkDurationTitle
            : strings.timerQuickRestDurationTitle,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.timerQuickDurationDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: context.spacing.lg),
          Text(
            valueLabel,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          Slider(
            value: _value.toDouble(),
            min: isDebugBuild ? 5 : (_isWork ? 1 : 10),
            max: isDebugBuild
                ? AppBuild.debugDurationSliderMax.inSeconds.toDouble()
                : (_isWork ? 180 : 600),
            divisions: isDebugBuild ? 55 : (_isWork ? 179 : 59),
            label: valueLabel,
            onChanged: (value) {
              setState(() {
                _value = isDebugBuild
                    ? value.round()
                    : _isWork
                    ? value.round()
                    : (value / 10).round() * 10;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.actionCancel),
        ),
        FilledButton(
          onPressed: () {
            final duration = isDebugBuild
                ? Duration(seconds: _value)
                : _isWork
                ? Duration(minutes: _value)
                : Duration(seconds: _value);
            Navigator.of(context).pop(duration);
          },
          child: Text(strings.actionSave),
        ),
      ],
    );
  }
}

class _TimerActions extends StatelessWidget {
  const _TimerActions({
    required this.phase,
    required this.executionStatus,
    required this.busy,
    required this.onStartWork,
    required this.onResumeWork,
    required this.onStartRest,
    required this.onSkipRest,
    required this.onStartWorkAfterRest,
    required this.onStop,
  });

  final TimerPhase phase;
  final ExecutionStatus executionStatus;
  final bool busy;
  final VoidCallback onStartWork;
  final VoidCallback onResumeWork;
  final VoidCallback onStartRest;
  final VoidCallback onSkipRest;
  final VoidCallback onStartWorkAfterRest;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final primary = executionStatus == ExecutionStatus.suspended
        ? (strings.actionResumeWork, Icons.play_arrow, onResumeWork)
        : switch (phase) {
            TimerPhase.idle => (
              strings.actionStartWork,
              Icons.play_arrow,
              onStartWork,
            ),
            TimerPhase.working || TimerPhase.awaitingRest => (
              strings.actionStartRest,
              Icons.self_improvement_outlined,
              onStartRest,
            ),
            TimerPhase.resting || TimerPhase.awaitingWork => (
              strings.actionStartWork,
              Icons.play_arrow,
              onStartWorkAfterRest,
            ),
          };
    final secondary = executionStatus == ExecutionStatus.suspended
        ? (strings.actionStopTimer, Icons.stop_outlined, onStop)
        : switch (phase) {
            TimerPhase.idle => null,
            TimerPhase.working => (
              strings.actionStopTimer,
              Icons.stop_outlined,
              onStop,
            ),
            TimerPhase.awaitingRest => (
              strings.actionSkipRest,
              Icons.skip_next,
              onSkipRest,
            ),
            TimerPhase.resting || TimerPhase.awaitingWork => (
              strings.actionStopTimer,
              Icons.stop_outlined,
              onStop,
            ),
          };
    return Wrap(
      spacing: context.spacing.md,
      runSpacing: context.spacing.sm,
      alignment: WrapAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: busy ? null : primary.$3,
          icon: Icon(primary.$2),
          label: Text(primary.$1),
        ),
        if (secondary != null)
          OutlinedButton.icon(
            onPressed: busy ? null : secondary.$3,
            icon: Icon(secondary.$2),
            label: Text(secondary.$1),
          ),
      ],
    );
  }
}

class _NotificationBanner extends StatelessWidget {
  const _NotificationBanner({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: EdgeInsets.all(context.spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              color: scheme.onSecondaryContainer,
            ),
            SizedBox(width: context.spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  SizedBox(height: context.spacing.xs),
                  Text(message),
                ],
              ),
            ),
            if (actionLabel != null && onPressed != null)
              TextButton(onPressed: onPressed, child: Text(actionLabel!)),
          ],
        ),
      ),
    );
  }
}
