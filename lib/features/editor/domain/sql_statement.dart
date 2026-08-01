import 'package:juno/features/editor/domain/sql_tokenizer.dart';

/// The broad category of a SQL statement.
enum StatementKind {
  /// A read: `SELECT`, `TABLE`, `VALUES`, `SHOW`, `EXPLAIN`.
  select,

  /// A row-level write: `INSERT`, `UPDATE`, `DELETE`, `MERGE`, `TRUNCATE`,
  /// or a `WITH` that contains one of those.
  write,

  /// Schema/DDL: `CREATE`, `ALTER`, `DROP`, `GRANT`, … .
  ddl,

  /// Anything else, or an empty statement.
  other,
}

/// A lightweight, good-enough SQL analysis — not a full parser.
///
/// It strips comments and literals, then inspects the first significant keyword.
/// Two consumers rely on it:
///  - **Pagination**: only a bare `SELECT` without its own `LIMIT` may
///    have `LIMIT/OFFSET` appended ([isPaginable]).
///  - **Read-only Layer 2 UX**: the [kind] drives the write warning.
class SqlStatement {
  const SqlStatement({
    required this.kind,
    required this.firstKeyword,
    required this.hasLimit,
    required this.normalized,
  });

  /// The statement category.
  final StatementKind kind;

  /// The first significant keyword, lower-cased (empty if none).
  final String firstKeyword;

  /// Whether a top-level (or any) `LIMIT` clause is present.
  final bool hasLimit;

  /// The statement trimmed of surrounding whitespace and trailing semicolons —
  /// safe to wrap with a `LIMIT/OFFSET` suffix.
  final String normalized;

  /// True when it is safe to append `LIMIT/OFFSET` for pagination: a statement
  /// that starts with `SELECT` and has no `LIMIT` of its own.
  bool get isPaginable => firstKeyword == 'select' && !hasLimit;

  static const Set<String> _writeKeywords = <String>{
    'insert',
    'update',
    'delete',
    'merge',
    'truncate',
  };

  static const Set<String> _ddlKeywords = <String>{
    'create',
    'alter',
    'drop',
    'grant',
    'revoke',
    'comment',
    'refresh',
    'reindex',
    'cluster',
    'vacuum',
    'analyze',
  };

  static const Set<String> _selectKeywords = <String>{
    'select',
    'table',
    'values',
    'show',
    'explain',
  };

  /// Classifies [sql].
  static SqlStatement classify(String sql) {
    final normalized = _normalize(sql);
    final words = SqlTokenizer.tokenize(
      sql,
    ).map((token) => token.lower).toList();

    final first = words.isEmpty ? '' : words.first;
    final hasLimit = words.contains('limit');
    final containsWrite = words.any(_writeKeywords.contains);

    final kind = switch (first) {
      _ when _writeKeywords.contains(first) => StatementKind.write,
      _ when _ddlKeywords.contains(first) => StatementKind.ddl,
      'with' => containsWrite ? StatementKind.write : StatementKind.select,
      _ when _selectKeywords.contains(first) => StatementKind.select,
      _ => StatementKind.other,
    };

    return SqlStatement(
      kind: kind,
      firstKeyword: first,
      hasLimit: hasLimit,
      normalized: normalized,
    );
  }

  static String _normalize(String sql) {
    var result = sql.trim();
    while (result.endsWith(';')) {
      result = result.substring(0, result.length - 1).trimRight();
    }
    return result;
  }
}
