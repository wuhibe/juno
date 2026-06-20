import 'dart:convert';

/// Formats a raw cell value for inline display in the grid.
///
/// NULL is the caller's concern (rendered as a styled `NULL`); this handles the
/// non-null cases: bytea as a truncated `\x…`, everything else via `toString`.
String formatCellValue(Object? value) {
  if (value == null) {
    return 'NULL';
  }
  if (value is List<int>) {
    return _bytea(value);
  }
  if (value is Map || value is List) {
    return jsonEncode(value);
  }
  return value.toString();
}

/// A stable, sortable key for a cell (string form; good enough for client-side
/// page sorting in v1).
String sortKey(Object? value) => value == null ? '' : formatCellValue(value);

/// Returns a pretty-printed JSON string when [value] is JSON-like (a decoded
/// Map/List, or a String that parses as JSON), otherwise null.
String? prettyJson(Object? value) {
  const encoder = JsonEncoder.withIndent('  ');
  try {
    if (value is Map || value is List) {
      return encoder.convert(value);
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        return encoder.convert(jsonDecode(trimmed));
      }
    }
  } on FormatException {
    return null;
  }
  return null;
}

String _bytea(List<int> bytes) {
  const max = 64;
  final hex = bytes
      .take(max)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  final suffix = bytes.length > max ? '… (${bytes.length} bytes)' : '';
  return '\\x$hex$suffix';
}
