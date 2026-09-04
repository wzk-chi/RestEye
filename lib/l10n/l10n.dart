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
) => resolveSupportedLocale(
  preference == AppLocalePreference.system ? null : preference.name,
  systemLocales,
);

/// Resolves the best supported locale from an explicit [localeCode] (null
/// means "follow the system locales") with the English ARB as final fallback.
Locale resolveSupportedLocale(
  String? localeCode,
  Iterable<Locale> systemLocales,
) {
  final override = localeCode == null ? null : Locale(localeCode);
  final candidates = override != null ? [override] : systemLocales;
  for (final locale in candidates) {
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
