import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rest_eye/app/theme/rest_eye_spacing.dart';
import 'package:rest_eye/l10n/generated/app_localizations.dart';

final aboutPackageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final packageInfo = ref.watch(aboutPackageInfoProvider);
    final version = packageInfo.when(
      data: (info) => info.version,
      loading: () => '…',
      error: (_, _) => '—',
    );
    return Scaffold(
      appBar: AppBar(title: Text(strings.aboutTitle)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.spacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(context.spacing.xl),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            'assets/brand/resteye_icon.png',
                            width: 72,
                            height: 72,
                          ),
                        ),
                        SizedBox(width: context.spacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.appFullName,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall,
                              ),
                              SizedBox(height: context.spacing.xs),
                              Text(strings.aboutVersion(version)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.spacing.md),
                _AboutCard(
                  icon: Icons.visibility_outlined,
                  title: strings.aboutGuidanceTitle,
                  body: strings.aboutGuidanceBody,
                ),
                SizedBox(height: context.spacing.md),
                _AboutCard(
                  icon: Icons.lock_outline,
                  title: strings.aboutPrivacyTitle,
                  body: strings.aboutPrivacyBody,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.spacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: context.spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: context.spacing.sm),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
