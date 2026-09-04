import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rest_eye/app/navigation/app_scaffold.dart';
import 'package:rest_eye/app/theme/rest_eye_theme.dart';
import 'package:rest_eye/features/settings/application/settings_dependencies.dart';
import 'package:rest_eye/features/settings/application/settings_controller.dart';
import 'package:rest_eye/features/settings/application/ports/window_behavior_gateway.dart';
import 'package:rest_eye/features/settings/domain/app_settings.dart';
import 'package:rest_eye/features/timer/domain/timer_phase.dart';
import 'package:rest_eye/features/timer/domain/timer_snapshot.dart';
import 'package:rest_eye/features/timer/presentation/timer_controller.dart';
import 'package:rest_eye/l10n/generated/app_localizations.dart';
import 'package:rest_eye/l10n/l10n.dart';

class RestEyeApp extends ConsumerWidget {
  const RestEyeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(
      settingsControllerProvider.select((state) {
        final settings = state.value?.saved ?? AppSettings.defaults;
        return (
          theme: settings.themePreference,
          locale: settings.localePreference,
        );
      }),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: RestEyeTheme.light,
      darkTheme: RestEyeTheme.dark,
      themeMode: resolveThemeMode(preferences.theme),
      locale: resolveLocaleOverride(preferences.locale),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _TrayMenuLocalizer(child: AppScaffold()),
    );
  }
}

class _TrayMenuLocalizer extends ConsumerStatefulWidget {
  const _TrayMenuLocalizer({required this.child});

  final Widget child;

  @override
  ConsumerState<_TrayMenuLocalizer> createState() => _TrayMenuLocalizerState();
}

class _TrayMenuLocalizerState extends ConsumerState<_TrayMenuLocalizer> {
  StreamSubscription<WindowTrayMenuAction>? _trayActionSubscription;
  Future<void> _syncTail = Future.value();
  String? _lastMenuSignature;

  @override
  void initState() {
    super.initState();
    _trayActionSubscription = ref
        .read(windowBehaviorGatewayProvider)
        .trayActions
        .listen((action) => unawaited(_dispatchTrayAction(action)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _queueTrayMenuSync();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<TimerViewState>(timerControllerProvider, (_, _) {
      _queueTrayMenuSync();
    });
    return widget.child;
  }

  void _queueTrayMenuSync() {
    if (!mounted) return;
    final strings = AppLocalizations.of(context);
    final items = _menuItems(
      strings,
      ref.read(timerControllerProvider).snapshot,
    );
    final signature = [
      strings.appTitle,
      strings.trayOpenApp,
      strings.trayExitApp,
      for (final item in items) '${item.action.name}:${item.label}',
    ].join('|');
    if (_lastMenuSignature == signature) return;
    _lastMenuSignature = signature;
    final update = (
      appTitle: strings.appTitle,
      openApp: strings.trayOpenApp,
      exitApp: strings.trayExitApp,
      items: items,
    );
    _syncTail = _syncTail.then((_) => _applyTrayMenu(update));
    unawaited(_syncTail);
  }

  Future<void> _applyTrayMenu(
    ({
      String appTitle,
      String openApp,
      String exitApp,
      List<WindowTrayMenuItem> items,
    })
    update,
  ) async {
    try {
      await ref
          .read(windowBehaviorGatewayProvider)
          .setTrayMenu(
            appTitle: update.appTitle,
            openApp: update.openApp,
            exitApp: update.exitApp,
            items: update.items,
          );
    } catch (_) {
      // Tray behavior is optional and must not prevent the Flutter UI from
      // starting if a platform adapter is unavailable.
    }
  }

  Future<void> _dispatchTrayAction(WindowTrayMenuAction action) async {
    if (!mounted) return;
    final controller = ref.read(timerControllerProvider.notifier);
    switch (action) {
      case WindowTrayMenuAction.startWork:
        await controller.startWork();
      case WindowTrayMenuAction.startWorkAfterRest:
        await controller.startWorkAfterRest();
      case WindowTrayMenuAction.resumeWork:
        await controller.resumeWork();
      case WindowTrayMenuAction.startRest:
        await controller.startRest();
      case WindowTrayMenuAction.stopTimer:
        await controller.stop();
    }
  }

  List<WindowTrayMenuItem> _menuItems(
    AppLocalizations strings,
    TimerSnapshot snapshot,
  ) {
    if (snapshot.executionStatus == ExecutionStatus.suspended) {
      return [
        WindowTrayMenuItem(
          action: WindowTrayMenuAction.resumeWork,
          label: strings.actionResumeWork,
        ),
        WindowTrayMenuItem(
          action: WindowTrayMenuAction.stopTimer,
          label: strings.actionStopTimer,
        ),
      ];
    }
    return switch (snapshot.phase) {
      TimerPhase.idle => [
        WindowTrayMenuItem(
          action: WindowTrayMenuAction.startWork,
          label: strings.actionStartWork,
        ),
      ],
      TimerPhase.working => [
        WindowTrayMenuItem(
          action: WindowTrayMenuAction.startRest,
          label: strings.actionStartRest,
        ),
        WindowTrayMenuItem(
          action: WindowTrayMenuAction.stopTimer,
          label: strings.actionStopTimer,
        ),
      ],
      TimerPhase.awaitingRest => [
        WindowTrayMenuItem(
          action: WindowTrayMenuAction.startRest,
          label: strings.actionStartRest,
        ),
        WindowTrayMenuItem(
          action: WindowTrayMenuAction.stopTimer,
          label: strings.actionStopTimer,
        ),
      ],
      TimerPhase.resting || TimerPhase.awaitingWork => [
        WindowTrayMenuItem(
          action: WindowTrayMenuAction.startWorkAfterRest,
          label: strings.actionStartWork,
        ),
        WindowTrayMenuItem(
          action: WindowTrayMenuAction.stopTimer,
          label: strings.actionStopTimer,
        ),
      ],
    };
  }

  @override
  void dispose() {
    unawaited(_trayActionSubscription?.cancel());
    super.dispose();
  }
}
