import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final aboutUpdateCheckerProvider = Provider<AboutUpdateChecker>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return AboutUpdateChecker(client: client);
});

final class AvailableRelease {
  const AvailableRelease({required this.version, required this.uri});

  final String version;
  final Uri uri;
}

final class AboutUpdateChecker {
  AboutUpdateChecker({required this._client});

  static final _latestReleaseUri = Uri.parse(
    'https://api.github.com/repos/wzk-chi/RestEye/releases/latest',
  );
  static final _versionPattern = RegExp(r'^[vV]?(\d+(?:\.\d+)*)(?:[-+].*)?$');
  static const _requestTimeout = Duration(seconds: 10);

  final http.Client _client;

  Future<AvailableRelease?> checkForUpdates({
    required String currentVersion,
  }) async {
    final response = await _client
        .get(
          _latestReleaseUri,
          headers: const {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
            'User-Agent': 'RestEye',
          },
        )
        .timeout(_requestTimeout);
    if (response.statusCode != 200) {
      throw const AboutUpdateCheckException();
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const AboutUpdateCheckException();
    }
    final tagName = decoded['tag_name'];
    final htmlUrl = decoded['html_url'];
    if (tagName is! String || htmlUrl is! String) {
      throw const AboutUpdateCheckException();
    }

    final latestVersion = _parseVersion(tagName);
    final installedVersion = _parseVersion(currentVersion);
    final releaseUri = Uri.tryParse(htmlUrl);
    if (latestVersion == null ||
        installedVersion == null ||
        releaseUri == null ||
        releaseUri.scheme != 'https' ||
        releaseUri.host != 'github.com') {
      throw const AboutUpdateCheckException();
    }
    if (_compareVersions(latestVersion, installedVersion) <= 0) {
      return null;
    }
    return AvailableRelease(version: tagName, uri: releaseUri);
  }

  static List<int>? _parseVersion(String value) {
    final match = _versionPattern.firstMatch(value.trim());
    final core = match?.group(1);
    if (core == null) return null;
    return core.split('.').map(int.tryParse).toList().cast<int>();
  }

  static int _compareVersions(List<int> left, List<int> right) {
    final length = left.length > right.length ? left.length : right.length;
    for (var index = 0; index < length; index++) {
      final leftPart = index < left.length ? left[index] : 0;
      final rightPart = index < right.length ? right[index] : 0;
      if (leftPart != rightPart) {
        return leftPart.compareTo(rightPart);
      }
    }
    return 0;
  }
}

final class AboutUpdateCheckException implements Exception {
  const AboutUpdateCheckException();
}
