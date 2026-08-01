import 'dart:convert';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_checker.g.dart';

/// Where releases are published. Juno ships as an APK attached to a GitHub
/// release, so "check for updates" is a look at the latest tag.
const String _releasesApi =
    'https://api.github.com/repos/wuhibe/juno/releases/latest';

/// A newer release than the one currently installed.
class AppUpdate {
  /// Creates an update descriptor.
  const AppUpdate({required this.version, required this.downloadUrl});

  /// The release version, without the `v` prefix (e.g. `1.1.0`).
  final String version;

  /// Where to get it: the APK asset when the release has one, else the
  /// release page.
  final Uri downloadUrl;

  @override
  String toString() => 'AppUpdate($version, $downloadUrl)';
}

/// The available update, or null when up to date, unreachable, or off Android.
///
/// Never throws: a failed update check must not interrupt someone trying to
/// query a database. Checked once per app launch (the provider is not
/// refreshed elsewhere).
@Riverpod(keepAlive: true)
Future<AppUpdate?> availableUpdate(Ref ref) async {
  // Only Android installs from a downloaded APK; iOS has no sideload path.
  if (!Platform.isAndroid) {
    return null;
  }
  try {
    final info = await PackageInfo.fromPlatform();
    final body = await _fetchLatestRelease();
    if (body == null) {
      return null;
    }
    return parseUpdate(body, currentVersion: info.version);
  } on Object {
    return null;
  }
}

/// Reads GitHub's release payload and returns the update it describes, or null
/// when it is not newer than [currentVersion].
///
/// Separate from the fetch so it can be tested without a network.
AppUpdate? parseUpdate(String responseBody, {required String currentVersion}) {
  final json = jsonDecode(responseBody);
  if (json is! Map<String, Object?>) {
    return null;
  }
  final tag = json['tag_name'];
  if (tag is! String || tag.isEmpty) {
    return null;
  }
  final version = tag.startsWith('v') ? tag.substring(1) : tag;
  if (!isNewerVersion(version, currentVersion)) {
    return null;
  }

  final assets = json['assets'];
  String? apkUrl;
  if (assets is List<Object?>) {
    for (final asset in assets) {
      if (asset is Map<String, Object?> &&
          asset['name'] is String &&
          (asset['name']! as String).toLowerCase().endsWith('.apk') &&
          asset['browser_download_url'] is String) {
        apkUrl = asset['browser_download_url']! as String;
        break;
      }
    }
  }
  final target = apkUrl ?? json['html_url'];
  if (target is! String) {
    return null;
  }
  final url = Uri.tryParse(target);
  return url == null ? null : AppUpdate(version: version, downloadUrl: url);
}

/// Whether [candidate] is a newer release than [current].
///
/// Compares the dotted numeric parts only, so a pre-release suffix
/// (`1.1.0-beta`) is treated as its base version and never outranks a build
/// with the same numbers.
bool isNewerVersion(String candidate, String current) {
  final a = _versionParts(candidate);
  final b = _versionParts(current);
  for (var i = 0; i < 3; i++) {
    final left = i < a.length ? a[i] : 0;
    final right = i < b.length ? b[i] : 0;
    if (left != right) {
      return left > right;
    }
  }
  return false;
}

List<int> _versionParts(String version) {
  // Drop a build suffix (`1.2.3+45`) and any pre-release tail (`1.2.3-beta`).
  final numeric = version.split('+').first.split('-').first;
  return <int>[
    for (final part in numeric.split('.')) int.tryParse(part.trim()) ?? 0,
  ];
}

Future<String?> _fetchLatestRelease() async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
  try {
    final request = await client.getUrl(Uri.parse(_releasesApi));
    request.headers
      ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
      // GitHub rejects API requests without a User-Agent.
      ..set(HttpHeaders.userAgentHeader, 'juno-app');
    final response = await request.close().timeout(const Duration(seconds: 10));
    if (response.statusCode != HttpStatus.ok) {
      return null;
    }
    return await response.transform(utf8.decoder).join();
  } finally {
    client.close();
  }
}
