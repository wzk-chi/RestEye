import 'package:flutter/material.dart';
import 'package:rest_eye/features/settings/domain/app_settings.dart';
import 'package:rest_eye/l10n/generated/app_localizations.dart';

Locale? resolveLocaleOverride(AppLocalePreference preference) =>
    switch (preference) {
      AppLocalePreference.system => null,
      AppLocalePreference.zh => const Locale('zh'),
      AppLocalePreference.en => const Locale('en'),
    };

Locale resolveEffectiveSupportedLocale(
  AppLocalePreference preference,
  Iterable<Locale> systemLocales,
) {
  final override = resolveLocaleOverride(preference);
  if (override != null) return override;
  for (final locale in systemLocales) {
    for (final supported in AppLocalizations.supportedLocales) {
      if (supported.languageCode == locale.languageCode) return supported;
    }
  }
  return AppLocalizations.supportedLocales.first;
}

ThemeMode resolveThemeMode(AppThemePreference preference) =>
    switch (preference) {
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
      AppThemePreference.system => ThemeMode.system,
    };

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
