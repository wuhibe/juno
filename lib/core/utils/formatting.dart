import 'package:flutter/widgets.dart';

/// A compact relative-time label (e.g. `just now`, `5m ago`, `3h ago`,
/// `2d ago`, then an absolute `d Mon` for older dates).
String relativeTime(DateTime time, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(time);

  if (diff.inSeconds < 45) {
    return 'just now';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}d ago';
  }

  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${time.day} ${months[time.month - 1]}';
}

/// Parses a `#RRGGBB` (or `#AARRGGBB`) string into a [Color], or null if [hex]
/// is null/blank/malformed.
Color? colorFromHex(String? hex) {
  if (hex == null) {
    return null;
  }
  var value = hex.trim().replaceFirst('#', '');
  if (value.length == 6) {
    value = 'FF$value';
  }
  if (value.length != 8) {
    return null;
  }
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? null : Color(parsed);
}

/// Formats the RGB of [color] as a `#RRGGBB` string.
String hexFromColor(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
