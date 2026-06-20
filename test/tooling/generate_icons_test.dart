// Launcher-icon generator (not a real test).
//
// Renders the Juno logo painter to PNGs at every Android mipmap and iOS app-icon
// size, writing them in place. Gated so it never runs in the normal suite:
//
//   fvm flutter test --dart-define=GEN_ICONS=true test/tooling/generate_icons_test.dart
//
// Re-run whenever the logo changes; commit the regenerated PNGs.

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juno/core/branding/juno_logo.dart';

const bool _enabled = bool.fromEnvironment('GEN_ICONS');

const Map<String, int> _androidMipmaps = <String, int>{
  'mipmap-mdpi': 48,
  'mipmap-hdpi': 72,
  'mipmap-xhdpi': 96,
  'mipmap-xxhdpi': 144,
  'mipmap-xxxhdpi': 192,
};

Future<Uint8List> _renderPng(int pixels) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  JunoLogoPainter.spec().paint(
    canvas,
    Size(pixels.toDouble(), pixels.toDouble()),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(pixels, pixels);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void main() {
  testWidgets('generate launcher icons', (tester) async {
    if (!_enabled) {
      markTestSkipped(
        'Set --dart-define=GEN_ICONS=true to (re)generate icons.',
      );
      return;
    }

    await tester.runAsync(() async {
      // Android legacy mipmap icons.
      for (final entry in _androidMipmaps.entries) {
        final bytes = await _renderPng(entry.value);
        File(
          'android/app/src/main/res/${entry.key}/ic_launcher.png',
        ).writeAsBytesSync(bytes);
      }

      // iOS app-icon set: filenames encode the size as <base>x<base>@<scale>x.
      final iosDir = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset');
      final pattern = RegExp(r'Icon-App-([\d.]+)x[\d.]+@(\d)x\.png$');
      for (final file in iosDir.listSync().whereType<File>()) {
        final match = pattern.firstMatch(file.path.split('/').last);
        if (match == null) {
          continue;
        }
        final base = double.parse(match.group(1)!);
        final scale = int.parse(match.group(2)!);
        final pixels = (base * scale).round();
        file.writeAsBytesSync(await _renderPng(pixels));
      }
    });
  });
}
