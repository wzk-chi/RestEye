import 'package:flutter/material.dart';

@immutable
class RestEyeSpacing extends ThemeExtension<RestEyeSpacing> {
  const RestEyeSpacing({
    this.xs = 4,
    this.sm = 8,
    this.md = 16,
    this.lg = 24,
    this.xl = 32,
    this.xxl = 48,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  @override
  RestEyeSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return RestEyeSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
    );
  }

  @override
  RestEyeSpacing lerp(covariant RestEyeSpacing? other, double t) {
    if (other == null) return this;
    return RestEyeSpacing(
      xs: xs + (other.xs - xs) * t,
      sm: sm + (other.sm - sm) * t,
      md: md + (other.md - md) * t,
      lg: lg + (other.lg - lg) * t,
      xl: xl + (other.xl - xl) * t,
      xxl: xxl + (other.xxl - xxl) * t,
    );
  }
}

extension RestEyeSpacingX on BuildContext {
  RestEyeSpacing get spacing =>
      Theme.of(this).extension<RestEyeSpacing>() ?? const RestEyeSpacing();
}
