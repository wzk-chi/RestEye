import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rest_eye/app/theme/rest_eye_spacing.dart';
import 'package:rest_eye/core/error/app_failure.dart';
import 'package:rest_eye/features/about/presentation/about_page.dart';
import 'package:rest_eye/features/settings/application/settings_controller.dart';
import 'package:rest_eye/features/settings/domain/app_settings.dart';
import 'package:rest_eye/features/timer/domain/timer_policy.dart';
import 'package:rest_eye/l10n/generated/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(settingsControllerProvider);
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.spacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: asyncState.when(
            data: (state) => _SettingsContent(state: state),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _SettingsError(
              onRetry: () => ref.invalidate(settingsControllerProvider),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsContent extends ConsumerWidget {
  const _SettingsContent({required this.state});

  final SettingsViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final controller = ref.read(settingsControllerProvider.notifier);
    final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    final isDesktop =
        isMacOS || defaultTargetPlatform == TargetPlatform.windows;
    final validationMessage = _validationMessage(
      strings,
      state.validationError,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings.settingsTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: context.spacing.lg),
        _SettingsSection(
          child: Column(
            children: [
              _PreferenceTile(
                title: strings.settingsThemeMode,
                valueLabel: _themePreferenceLabel(
                  strings,
                  state.draft.themePreference,
                ),
                onTap: () => _selectThemePreference(
                  context,
                  controller,
                  state.draft.themePreference,
                ),
              ),
              const Divider(height: 1),
              _PreferenceTile(
                title: strings.settingsLanguage,
                valueLabel: _localePreferenceLabel(
                  strings,
                  state.draft.localePreference,
                ),
                onTap: () => _selectLocalePreference(
                  context,
                  controller,
                  state.draft.localePreference,
                ),
              ),
              if (defaultTargetPlatform == TargetPlatform.android) ...[
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(strings.settingsFixedPortrait),
                  subtitle: Text(strings.settingsFixedPortraitDescription),
                  value: state.draft.fixedPortraitEnabled,
                  onChanged: controller.setFixedPortraitEnabled,
                ),
              ],
              if (isDesktop) ...[
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(
                    isMacOS
                        ? strings.settingsKeepInMenuBarOnClose
                        : strings.settingsMinimizeToTrayOnClose,
                  ),
                  subtitle: Text(
                    isMacOS
                        ? strings.settingsKeepInMenuBarOnCloseDescription
                        : strings.settingsMinimizeToTrayOnCloseDescription,
                  ),
                  value: state.draft.minimizeToTrayOnClose,
                  onChanged: controller.setMinimizeToTrayOnClose,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: context.spacing.lg),
        _SettingsSection(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: context.spacing.sm),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(strings.settingsWorkReminder),
                  subtitle: Text(strings.settingsWorkReminderDescription),
                  value: state.draft.workReminderEnabled,
                  onChanged: controller.setWorkReminderEnabled,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(strings.settingsRestReminder),
                  subtitle: Text(strings.settingsRestReminderDescription),
                  value: state.draft.restReminderEnabled,
                  onChanged: controller.setRestReminderEnabled,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(strings.settingsMissedRestReminder),
                  subtitle: Text(strings.settingsMissedRestReminderDescription),
                  value: state.draft.missedRestReminderEnabled,
                  onChanged: controller.setMissedRestReminderEnabled,
                ),
                const Divider(height: 1),
                _DurationSlider(
                  title: strings.settingsReminderInterval,
                  value: state.draft.reminderInterval.inMinutes.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  valueLabel: strings.settingsMinutesValue(
                    state.draft.reminderInterval.inMinutes,
                  ),
                  onChanged: (value) => controller.setReminderInterval(
                    Duration(minutes: value.round()),
                  ),
                ),
                if (defaultTargetPlatform == TargetPlatform.android) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(strings.settingsVibration),
                    value: state.draft.androidVibrationEnabled,
                    onChanged: controller.setAndroidVibrationEnabled,
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: context.spacing.lg),
        _SettingsSection(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: context.spacing.sm),
            child: Column(
              children: [
                _DurationSlider(
                  title: strings.settingsWorkDuration,
                  value: state.draft.workDuration.inMinutes.toDouble(),
                  min: 1,
                  max: 180,
                  divisions: 179,
                  valueLabel: strings.settingsMinutesValue(
                    state.draft.workDuration.inMinutes,
                  ),
                  onChanged: (value) => controller.setWorkDuration(
                    Duration(minutes: value.round()),
                  ),
                ),
                const Divider(height: 1),
                _DurationSlider(
                  title: strings.settingsRestDuration,
                  value: state.draft.restDuration.inSeconds.toDouble(),
                  min: 10,
                  max: 600,
                  divisions: 59,
                  valueLabel: strings.settingsSecondsValue(
                    state.draft.restDuration.inSeconds,
                  ),
                  onChanged: (value) => controller.setRestDuration(
                    Duration(seconds: (value / 10).round() * 10),
                  ),
                ),
                const Divider(height: 1),
                _RestCompletionBehaviorSelector(
                  value: state.draft.restCompletionBehavior,
                  onChanged: controller.setRestCompletionBehavior,
                ),
                const Divider(height: 1),
                _DurationSlider(
                  title: strings.settingsReminderTimeout,
                  value: state.draft.reminderTimeout.inMinutes.toDouble(),
                  min: 2,
                  max: 120,
                  divisions: 118,
                  valueLabel: strings.settingsMinutesValue(
                    state.draft.reminderTimeout.inMinutes,
                  ),
                  onChanged: (value) => controller.setReminderTimeout(
                    Duration(minutes: value.round()),
                  ),
                ),
                const Divider(height: 1),
                _TimeoutBehaviorSelector(
                  value: state.draft.timeoutBehavior,
                  onChanged: controller.setTimeoutBehavior,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(strings.settingsPauseWhenLocked),
                  subtitle: Text(strings.settingsPauseWhenLockedDescription),
                  value: state.draft.pauseWhenLocked,
                  onChanged: controller.setPauseWhenLocked,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: context.spacing.lg),
        _SettingsSection(
          child: ListTile(
            title: Text(strings.navigationAbout),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => const AboutPage()),
            ),
          ),
        ),
        if (validationMessage != null) ...[
          SizedBox(height: context.spacing.md),
          Text(
            validationMessage,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        if (state.saving) ...[
          SizedBox(height: context.spacing.md),
          Row(
            children: [
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: context.spacing.sm),
              Text(strings.settingsSaving),
            ],
          ),
        ] else if (state.savedNotice) ...[
          SizedBox(height: context.spacing.md),
          Text(
            strings.settingsSaved,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ],
        if (state.saveFailureCode != null) ...[
          SizedBox(height: context.spacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.settingsAutoSaveFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              TextButton(
                onPressed: state.saving ? null : controller.retrySave,
                child: Text(strings.actionRetry),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _selectThemePreference(
    BuildContext context,
    SettingsController controller,
    AppThemePreference current,
  ) async {
    final strings = AppLocalizations.of(context);
    final selected = await showDialog<AppThemePreference>(
      context: context,
      builder: (context) => _PreferenceDialog<AppThemePreference>(
        title: strings.settingsThemeMode,
        current: current,
        options: [
          (
            value: AppThemePreference.system,
            label: strings.settingsThemeSystem,
          ),
          (value: AppThemePreference.light, label: strings.settingsThemeLight),
          (value: AppThemePreference.dark, label: strings.settingsThemeDark),
        ],
      ),
    );
    if (selected != null) controller.setThemePreference(selected);
  }

  Future<void> _selectLocalePreference(
    BuildContext context,
    SettingsController controller,
    AppLocalePreference current,
  ) async {
    final strings = AppLocalizations.of(context);
    final selected = await showDialog<AppLocalePreference>(
      context: context,
      builder: (context) => _PreferenceDialog<AppLocalePreference>(
        title: strings.settingsLanguage,
        current: current,
        options: [
          (
            value: AppLocalePreference.system,
            label: strings.settingsLanguageSystem,
          ),
          (
            value: AppLocalePreference.zh,
            label: strings.settingsLanguageChinese,
          ),
          (
            value: AppLocalePreference.en,
            label: strings.settingsLanguageEnglish,
          ),
        ],
      ),
    );
    if (selected != null) controller.setLocalePreference(selected);
  }

  String _themePreferenceLabel(
    AppLocalizations strings,
    AppThemePreference preference,
  ) => switch (preference) {
    AppThemePreference.system => strings.settingsThemeSystem,
    AppThemePreference.light => strings.settingsThemeLight,
    AppThemePreference.dark => strings.settingsThemeDark,
  };

  String _localePreferenceLabel(
    AppLocalizations strings,
    AppLocalePreference preference,
  ) => switch (preference) {
    AppLocalePreference.system => strings.settingsLanguageSystem,
    AppLocalePreference.zh => strings.settingsLanguageChinese,
    AppLocalePreference.en => strings.settingsLanguageEnglish,
  };

  String? _validationMessage(
    AppLocalizations strings,
    ValidationFailureCode? code,
  ) {
    return switch (code) {
      null => null,
      ValidationFailureCode.workDurationOutOfRange =>
        strings.validationWorkRange,
      ValidationFailureCode.restDurationOutOfRange =>
        strings.validationRestRange,
      ValidationFailureCode.reminderIntervalOutOfRange =>
        strings.validationReminderRange,
      ValidationFailureCode.reminderTimeoutOutOfRange =>
        strings.validationTimeoutRange,
      ValidationFailureCode.reminderTimeoutNotAfterInterval =>
        strings.validationTimeoutAfterInterval,
    };
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(clipBehavior: Clip.antiAlias, child: child);
  }
}

class _TimeoutBehaviorSelector extends StatelessWidget {
  const _TimeoutBehaviorSelector({
    required this.value,
    required this.onChanged,
  });

  final TimeoutBehavior value;
  final ValueChanged<TimeoutBehavior> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.spacing.md,
        context.spacing.md,
        context.spacing.md,
        context.spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.settingsTimeoutBehavior,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: context.spacing.md),
          SegmentedButton<TimeoutBehavior>(
            segments: [
              ButtonSegment<TimeoutBehavior>(
                value: TimeoutBehavior.nextCycle,
                label: Text(strings.settingsTimeoutNextCycle),
              ),
              ButtonSegment<TimeoutBehavior>(
                value: TimeoutBehavior.stopTimer,
                label: Text(strings.settingsTimeoutStopTimer),
              ),
            ],
            selected: {value},
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) onChanged(selection.first);
            },
            showSelectedIcon: false,
          ),
        ],
      ),
    );
  }
}

class _RestCompletionBehaviorSelector extends StatelessWidget {
  const _RestCompletionBehaviorSelector({
    required this.value,
    required this.onChanged,
  });

  final RestCompletionBehavior value;
  final ValueChanged<RestCompletionBehavior> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.spacing.md,
        context.spacing.md,
        context.spacing.md,
        context.spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.settingsRestCompletionBehavior,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: context.spacing.md),
          SegmentedButton<RestCompletionBehavior>(
            segments: [
              ButtonSegment<RestCompletionBehavior>(
                value: RestCompletionBehavior.startWork,
                label: Text(strings.settingsRestCompletionStartWork),
              ),
              ButtonSegment<RestCompletionBehavior>(
                value: RestCompletionBehavior.stopTimer,
                label: Text(strings.settingsRestCompletionStopTimer),
              ),
              ButtonSegment<RestCompletionBehavior>(
                value: RestCompletionBehavior.continueRest,
                label: Text(strings.settingsRestCompletionContinueRest),
              ),
            ],
            selected: {value},
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) onChanged(selection.first);
            },
            showSelectedIcon: false,
          ),
        ],
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.title,
    required this.valueLabel,
    required this.onTap,
  });

  final String title;
  final String valueLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(valueLabel),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

typedef _PreferenceOption<T> = ({T value, String label});

class _PreferenceDialog<T> extends StatelessWidget {
  const _PreferenceDialog({
    required this.title,
    required this.current,
    required this.options,
  });

  final String title;
  final T current;
  final List<_PreferenceOption<T>> options;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(title),
      contentPadding: EdgeInsets.only(
        left: context.spacing.sm,
        top: context.spacing.sm,
        right: context.spacing.sm,
        bottom: context.spacing.md,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            ListTile(
              title: Text(option.label),
              trailing: Icon(
                option.value == current
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: option.value == current ? scheme.primary : null,
              ),
              selected: option.value == current,
              onTap: () => Navigator.of(context).pop(option.value),
            ),
        ],
      ),
    );
  }
}

class _DurationSlider extends StatelessWidget {
  const _DurationSlider({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueLabel,
    required this.onChanged,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueLabel;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: textTheme.bodyLarge)),
              Text(
                valueLabel,
                style: textTheme.bodyMedium?.copyWith(color: scheme.primary),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: valueLabel,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(strings.commandFailed),
        SizedBox(height: context.spacing.md),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(strings.actionRetry),
        ),
      ],
    );
  }
}
