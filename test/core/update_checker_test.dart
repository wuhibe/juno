import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:juno/core/update/update_checker.dart';

String _release({
  required String tag,
  List<String> assetNames = const <String>['Juno-v9.9.9.apk'],
}) {
  return jsonEncode(<String, Object?>{
    'tag_name': tag,
    'html_url': 'https://github.com/wuhibe/juno/releases/tag/$tag',
    'assets': <Object?>[
      for (final name in assetNames)
        <String, Object?>{
          'name': name,
          'browser_download_url':
              'https://github.com/wuhibe/juno/releases/download/$tag/$name',
        },
    ],
  });
}

void main() {
  group('isNewerVersion', () {
    test('compares numerically, not lexically', () {
      expect(isNewerVersion('1.0.10', '1.0.9'), isTrue);
      expect(isNewerVersion('1.0.9', '1.0.10'), isFalse);
      expect(isNewerVersion('2.0.0', '1.99.99'), isTrue);
    });

    test('an equal version is not newer', () {
      expect(isNewerVersion('1.2.3', '1.2.3'), isFalse);
    });

    test('missing parts count as zero', () {
      expect(isNewerVersion('1.1', '1.0.9'), isTrue);
      expect(isNewerVersion('1.0', '1.0.0'), isFalse);
    });

    test('build and pre-release suffixes do not outrank the base version', () {
      expect(isNewerVersion('1.2.3+9', '1.2.3'), isFalse);
      expect(isNewerVersion('1.2.3-beta', '1.2.3'), isFalse);
      expect(isNewerVersion('1.2.4-beta', '1.2.3'), isTrue);
    });
  });

  group('parseUpdate', () {
    test('returns the APK asset for a newer tag', () {
      final update = parseUpdate(
        _release(tag: 'v1.1.0'),
        currentVersion: '1.0.2',
      );
      expect(update?.version, '1.1.0');
      expect(update?.downloadUrl.path, endsWith('.apk'));
    });

    test('returns null when the latest release is the installed one', () {
      expect(
        parseUpdate(_release(tag: 'v1.0.2'), currentVersion: '1.0.2'),
        isNull,
      );
    });

    test('falls back to the release page when there is no APK asset', () {
      final update = parseUpdate(
        _release(tag: 'v1.1.0', assetNames: <String>['sources.zip']),
        currentVersion: '1.0.2',
      );
      expect(update?.downloadUrl.toString(), contains('/releases/tag/v1.1.0'));
    });

    test('tolerates a tag without the v prefix', () {
      final update = parseUpdate(
        _release(tag: '1.1.0'),
        currentVersion: '1.0.2',
      );
      expect(update?.version, '1.1.0');
    });

    test('returns null for a payload without a tag', () {
      expect(parseUpdate('{}', currentVersion: '1.0.2'), isNull);
      expect(parseUpdate('[]', currentVersion: '1.0.2'), isNull);
    });
  });
}
