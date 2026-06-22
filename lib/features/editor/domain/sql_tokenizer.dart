/// A single word token produced by [SqlTokenizer].
///
/// Only identifier/keyword words are emitted; comments, string/identifier
/// literals and dollar-quoted blocks are skipped entirely so their contents can
/// never be mistaken for SQL words.
class SqlToken {
  /// Creates a token spanning `[start, end)` of the source.
  const SqlToken({
    required this.text,
    required this.start,
    required this.end,
    required this.precededByDot,
  });

  /// The raw word as it appears in the source.
  final String text;

  /// Inclusive start offset in the original SQL.
  final int start;

  /// Exclusive end offset in the original SQL.
  final int end;

  /// Whether a `.` sits immediately before this token (e.g. the `name` in
  /// `users.name`). Drives alias/column qualification in autocomplete.
  final bool precededByDot;

  /// The word lower-cased — keyword and identifier matching is case-insensitive.
  String get lower => text.toLowerCase();

  @override
  String toString() => 'SqlToken($text @$start..$end)';
}

/// A lightweight SQL lexer — good enough for classification and autocomplete,
/// not a full parser.
///
/// It walks the source once, skipping comments and any quoted content, and
/// yields the word tokens (with their source positions) that remain. Both the
/// statement classifier ([SqlStatement]) and the autocomplete engine build on
/// this single pass so they agree on what counts as a "word".
abstract final class SqlTokenizer {
  /// Tokenizes [sql] into its significant word tokens.
  static List<SqlToken> tokenize(String sql) {
    final tokens = <SqlToken>[];
    final n = sql.length;
    var i = 0;
    var dotBeforeNext = false;

    while (i < n) {
      final c = sql[i];
      final next = i + 1 < n ? sql[i + 1] : '';

      // Line comment: -- ... EOL
      if (c == '-' && next == '-') {
        while (i < n && sql[i] != '\n') {
          i++;
        }
        dotBeforeNext = false;
        continue;
      }
      // Block comment: /* ... */
      if (c == '/' && next == '*') {
        i += 2;
        while (i < n && !(sql[i] == '*' && i + 1 < n && sql[i + 1] == '/')) {
          i++;
        }
        i += 2;
        dotBeforeNext = false;
        continue;
      }
      // Single-quoted string (with '' escape).
      if (c == "'") {
        i++;
        while (i < n) {
          if (sql[i] == "'") {
            if (i + 1 < n && sql[i + 1] == "'") {
              i += 2;
              continue;
            }
            i++;
            break;
          }
          i++;
        }
        dotBeforeNext = false;
        continue;
      }
      // Double-quoted identifier.
      if (c == '"') {
        i++;
        while (i < n && sql[i] != '"') {
          i++;
        }
        i++;
        dotBeforeNext = false;
        continue;
      }
      // Dollar-quoted string: $tag$ ... $tag$.
      if (c == r'$') {
        final tagEnd = sql.indexOf(r'$', i + 1);
        if (tagEnd != -1) {
          final tag = sql.substring(i, tagEnd + 1);
          final close = sql.indexOf(tag, tagEnd + 1);
          if (close != -1) {
            i = close + tag.length;
            dotBeforeNext = false;
            continue;
          }
        }
      }
      // A word: [A-Za-z_][A-Za-z0-9_]*
      if (_isWordStart(c)) {
        final start = i;
        i++;
        while (i < n && _isWordPart(sql[i])) {
          i++;
        }
        tokens.add(
          SqlToken(
            text: sql.substring(start, i),
            start: start,
            end: i,
            precededByDot: dotBeforeNext,
          ),
        );
        dotBeforeNext = false;
        continue;
      }

      dotBeforeNext = c == '.';
      i++;
    }

    return tokens;
  }

  static bool _isWordStart(String c) {
    final u = c.codeUnitAt(0);
    return (u >= 65 && u <= 90) || (u >= 97 && u <= 122) || u == 95;
  }

  static bool _isWordPart(String c) {
    final u = c.codeUnitAt(0);
    return (u >= 65 && u <= 90) ||
        (u >= 97 && u <= 122) ||
        (u >= 48 && u <= 57) ||
        u == 95;
  }
}
