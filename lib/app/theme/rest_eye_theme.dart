import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rest_eye/app/theme/rest_eye_spacing.dart';

abstract final class RestEyeTheme {
  // Keep one brand seed for both brightness modes so the Material 3
  // tonal palettes remain recognizably RestEye across every platform.
  static const _seedColor = Color(0xFF6B9FE8);

  static ThemeData get light => _build(Brightness.light, _seedColor);
  static ThemeData get dark => _build(Brightness.dark, _seedColor);

  static ThemeData _build(Brightness brightness, Color seed) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamilyFallback: _systemFontFallbacks,
      visualDensity: VisualDensity.standard,
      extensions: const [RestEyeSpacing()],
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: rounded,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size.square(44)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        minWidth: 80,
        groupAlignment: -0.82,
        labelType: NavigationRailLabelType.all,
      ),
    );
  }

  static List<String> get _systemFontFallbacks =>
      switch (defaultTargetPlatform) {
        TargetPlatform.windows => const [
          'Microsoft YaHei UI',
          'Microsoft YaHei',
          'DengXian',
        ],
        TargetPlatform.macOS ||
        TargetPlatform.iOS => const ['PingFang SC', 'Hiragino Sans GB'],
        TargetPlatform.android ||
        TargetPlatform.fuchsia => const ['Noto Sans CJK SC', 'Noto Sans SC'],
        TargetPlatform.linux => const ['Noto Sans CJK SC', 'WenQuanYi Zen Hei'],
      };
}
