import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rest_eye/app/theme/rest_eye_spacing.dart';
import 'package:rest_eye/features/about/application/about_update_checker.dart';
import 'package:rest_eye/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

final _repositoryUri = Uri.parse('https://github.com/wzk-chi/RestEye');

final aboutPackageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  var _checkingForUpdates = false;

  @override
  Widget build(BuildContext context) {
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
                              SizedBox(height: context.spacing.md),
                              OutlinedButton.icon(
                                onPressed: _checkingForUpdates
                                    ? null
                                    : _checkForUpdates,
                                icon: _checkingForUpdates
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.system_update_outlined),
                                label: Text(
                                  _checkingForUpdates
                                      ? strings.aboutCheckForUpdatesChecking
                                      : strings.aboutCheckForUpdates,
                                ),
                              ),
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
                  icon: Icons.timer_outlined,
                  title: strings.aboutPomodoroTitle,
                  body: strings.aboutPomodoroBody,
                ),
                SizedBox(height: context.spacing.md),
                _AboutCard(
                  icon: Icons.lock_outline,
                  title: strings.aboutPrivacyTitle,
                  body: strings.aboutPrivacyBody,
                ),
                SizedBox(height: context.spacing.md),
                _AboutCard(
                  icon: Icons.code_outlined,
                  title: strings.aboutRepositoryTitle,
                  body: strings.aboutRepositoryBody,
                  onTap: () => _openRepository(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    setState(() => _checkingForUpdates = true);
    final strings = AppLocalizations.of(context);
    try {
      final packageInfo = await ref.read(aboutPackageInfoProvider.future);
      final release = await ref
          .read(aboutUpdateCheckerProvider)
          .checkForUpdates(currentVersion: packageInfo.version);
      if (!mounted) return;

      if (release == null) {
        _showMessage(strings.aboutAlreadyLatest);
        return;
      }

      final openRelease = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(strings.aboutUpdateAvailableTitle),
          content: Text(strings.aboutUpdateAvailableMessage(release.version)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(strings.aboutUpdateLater),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(strings.aboutUpdateOpenRelease),
            ),
          ],
        ),
      );
      if (openRelease != true || !mounted) return;

      final opened = await launchUrl(
        release.uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        _showMessage(strings.aboutReleaseOpenFailed);
      }
    } catch (_) {
      if (mounted) _showMessage(strings.aboutUpdateCheckFailed);
    } finally {
      if (mounted) setState(() => _checkingForUpdates = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({
    required this.icon,
    required this.title,
    required this.body,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
              if (onTap != null) ...[
                SizedBox(width: context.spacing.md),
                Icon(
                  Icons.open_in_new,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openRepository(BuildContext context) async {
  final strings = AppLocalizations.of(context);
  final opened = await launchUrl(
    _repositoryUri,
    mode: LaunchMode.externalApplication,
  );
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.aboutRepositoryOpenFailed)));
  }
}
