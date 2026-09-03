import 'package:flutter/material.dart';
import 'package:rest_eye/app/navigation/app_section.dart';
import 'package:rest_eye/features/settings/presentation/settings_page.dart';
import 'package:rest_eye/features/statistics/presentation/statistics_page.dart';
import 'package:rest_eye/features/timer/presentation/timer_page.dart';
import 'package:rest_eye/l10n/generated/app_localizations.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  var _selected = AppSection.home;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final destinations = _destinations(strings);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        final content = IndexedStack(
          index: _selected.index,
          children: [
            _selected == AppSection.home
                ? const TimerPage()
                : const SizedBox.shrink(),
            _selected == AppSection.statistics
                ? const StatisticsPage()
                : const SizedBox.shrink(),
            _selected == AppSection.settings
                ? const SettingsPage()
                : const SizedBox.shrink(),
          ],
        );
        final safeContent = SafeArea(top: true, bottom: false, child: content);
        return Scaffold(
          body: compact
              ? safeContent
              : Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _selected.index,
                      onDestinationSelected: _select,
                      destinations: [
                        for (final destination in destinations)
                          NavigationRailDestination(
                            icon: Icon(destination.icon),
                            selectedIcon: Icon(destination.selectedIcon),
                            label: Text(destination.label),
                          ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: safeContent),
                  ],
                ),
          bottomNavigationBar: compact
              ? NavigationBar(
                  selectedIndex: _selected.index,
                  onDestinationSelected: _select,
                  destinations: [
                    for (final destination in destinations)
                      NavigationDestination(
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon),
                        label: destination.label,
                        tooltip: strings.accessibilityOpenSection(
                          destination.label,
                        ),
                      ),
                  ],
                )
              : null,
        );
      },
    );
  }

  void _select(int index) {
    setState(() => _selected = AppSection.values[index]);
  }

  List<_Destination> _destinations(AppLocalizations strings) {
    return [
      _Destination(
        icon: Icons.timer_outlined,
        selectedIcon: Icons.timer,
        label: strings.navigationHome,
      ),
      _Destination(
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart,
        label: strings.navigationStatistics,
      ),
      _Destination(
        icon: Icons.tune_outlined,
        selectedIcon: Icons.tune,
        label: strings.navigationSettings,
      ),
    ];
  }
}

final class _Destination {
  const _Destination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
