import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rest_eye/app/theme/rest_eye_theme.dart';
import 'package:rest_eye/l10n/generated/app_localizations.dart';

class BootstrapFailureApp extends StatefulWidget {
  const BootstrapFailureApp({required this.onRetry, super.key});

  final Future<void> Function() onRetry;

  @override
  State<BootstrapFailureApp> createState() => _BootstrapFailureAppState();
}

class _BootstrapFailureAppState extends State<BootstrapFailureApp> {
  var _retrying = false;

  Future<void> _retry() async {
    if (_retrying) return;
    setState(() => _retrying = true);
    await widget.onRetry();
    if (mounted) setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: RestEyeTheme.light,
      darkTheme: RestEyeTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final strings = AppLocalizations.of(context);
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              strings.bootstrapFailureTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              strings.bootstrapFailureMessage,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: [
                                FilledButton.icon(
                                  onPressed: _retrying ? null : _retry,
                                  icon: _retrying
                                      ? const SizedBox.square(
                                          dimension: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.refresh),
                                  label: Text(strings.actionRetry),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _retrying
                                      ? null
                                      : SystemNavigator.pop,
                                  icon: const Icon(Icons.close),
                                  label: Text(strings.actionExit),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
