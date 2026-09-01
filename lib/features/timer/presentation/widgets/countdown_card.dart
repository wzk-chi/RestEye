import 'package:flutter/material.dart';
import 'package:rest_eye/app/theme/rest_eye_spacing.dart';

class CountdownCard extends StatelessWidget {
  static const _minimumHeight = 348.0;

  const CountdownCard({
    required this.phase,
    required this.message,
    required this.time,
    required this.elapsedLabel,
    required this.progress,
    required this.progressSemantics,
    required this.timeSemantics,
    required this.accentColor,
    super.key,
  });

  final String phase;
  final String message;
  final String time;
  final String elapsedLabel;
  final double progress;
  final String progressSemantics;
  final String timeSemantics;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final messageStyle = Theme.of(context).textTheme.bodyLarge
        ?.copyWith(color: scheme.onSurfaceVariant);
    final messageFontSize = messageStyle?.fontSize ?? 16;
    final messageLineHeight =
        MediaQuery.textScalerOf(context).scale(messageFontSize) *
        (messageStyle?.height ?? 1.5);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _minimumHeight),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.xl),
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing.md,
                    vertical: context.spacing.sm,
                  ),
                  child: Text(
                    phase,
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: accentColor),
                  ),
                ),
              ),
              SizedBox(height: context.spacing.lg),
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: messageLineHeight * 3),
                child: Center(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: messageStyle,
                  ),
                ),
              ),
              SizedBox(height: context.spacing.xl),
              Text(
                elapsedLabel,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              SizedBox(height: context.spacing.xs),
              Semantics(
                label: timeSemantics,
                liveRegion: true,
                child: ExcludeSemantics(
                  child: Text(
                    time,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.spacing.lg),
              Semantics(
                label: progressSemantics,
                child: LinearProgressIndicator(
                  value: progress,
                  color: accentColor,
                  backgroundColor: accentColor.withValues(alpha: 0.16),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
