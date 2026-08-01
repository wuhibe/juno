import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:juno/features/editor/domain/sql_schema_snapshot.dart';
import 'package:juno/features/editor/domain/sql_suggestion.dart';
import 'package:juno/features/editor/domain/sql_tokenizer.dart';

/// Context-aware SQL autocomplete.
///
/// A pure function of the current line, the cursor offset, and a
/// [SqlSchemaSnapshot]: it decides which clause the cursor sits in, which
/// tables the statement references, and returns a ranked suggestion list. All
/// async schema loading happens before this is called.
///
/// Limitation: re_editor hands the prompts builder only the *current line*, so
/// table/alias references on other lines of a multi-line statement are not
/// visible. Good enough for v1; the snippet toolbar covers the rest.
class SqlAutocompleteEngine {
  /// Creates an engine over [snapshot].
  const SqlAutocompleteEngine(this.snapshot);

  /// The schema data backing table/column suggestions.
  final SqlSchemaSnapshot snapshot;

  /// Maximum suggestions returned in one pass.
  static const int maxSuggestions = 50;

  /// The bare table names referenced by `FROM`/`JOIN`/`INTO`/`UPDATE` in
  /// [line]. The widget layer uses this to lazily warm the column cache for the
  /// tables a statement actually touches.
  static List<String> referencedTableNames(String line) =>
      _references(line).tables;

  /// Suggestions for the cursor at [cursor] within [line].
  List<SqlSuggestion> suggest(String line, int cursor) {
    final before = line.substring(0, cursor.clamp(0, line.length));
    final partial = _trailingWord(before);
    final qualifier = _qualifierBefore(before, partial);
    final clause = _clauseKeyword(before, hasPartial: partial.isNotEmpty);
    final references = _references(line);

    // `alias.` or `table.` → that table's columns only.
    if (qualifier != null) {
      final table = references.aliases[qualifier.toLowerCase()] ?? qualifier;
      return _filterColumns(snapshot.columnsFor(table), partial);
    }

    switch (clause) {
      case _Clause.table:
        return _filterTables(partial);
      case _Clause.column:
        final columns = _columnsFor(references.tables);
        return <SqlSuggestion>[
          ..._filterColumns(columns, partial),
          ..._filterKeywords(partial),
        ].take(maxSuggestions).toList();
      case _Clause.statementStart:
        // Don't dump every keyword on an empty buffer; wait for a prefix.
        return partial.isEmpty
            ? const <SqlSuggestion>[]
            : _filterKeywords(partial);
    }
  }

  List<SqlSuggestion> _filterTables(String partial) {
    final lower = partial.toLowerCase();
    final out = <SqlSuggestion>[];
    for (final table in snapshot.tables) {
      if (lower.isEmpty || table.name.toLowerCase().startsWith(lower)) {
        out.add(
          SqlSuggestion(
            label: table.name,
            insertText: table.name,
            kind: SqlSuggestionKind.table,
            detail: table.schema,
          ),
        );
        if (out.length >= maxSuggestions) break;
      }
    }
    return out;
  }

  List<SqlSuggestion> _filterColumns(List<DbColumn> columns, String partial) {
    final lower = partial.toLowerCase();
    final out = <SqlSuggestion>[];
    for (final column in columns) {
      if (lower.isEmpty || column.name.toLowerCase().startsWith(lower)) {
        out.add(
          SqlSuggestion(
            label: column.name,
            insertText: column.name,
            kind: SqlSuggestionKind.column,
            detail: column.dataType,
          ),
        );
      }
    }
    return out;
  }

  List<SqlSuggestion> _filterKeywords(String partial) {
    final lower = partial.toLowerCase();
    if (lower.isEmpty) return const <SqlSuggestion>[];
    return _keywords
        .where((keyword) => keyword.toLowerCase().startsWith(lower))
        .map(
          (keyword) => SqlSuggestion(
            label: keyword,
            insertText: keyword,
            kind: SqlSuggestionKind.keyword,
          ),
        )
        .toList();
  }

  /// Columns of every referenced table, de-duplicated by name (first wins).
  List<DbColumn> _columnsFor(List<String> tables) {
    final seen = <String>{};
    final out = <DbColumn>[];
    for (final table in tables) {
      for (final column in snapshot.columnsFor(table)) {
        if (seen.add(column.name.toLowerCase())) {
          out.add(column);
        }
      }
    }
    return out;
  }

  /// The trailing identifier being typed (empty if the cursor follows a
  /// non-word character).
  static String _trailingWord(String before) {
    return RegExp(r'[A-Za-z_]\w*$').firstMatch(before)?.group(0) ?? '';
  }

  /// The `qualifier` in `qualifier.partial`, if a dot directly precedes the
  /// partial word.
  static String? _qualifierBefore(String before, String partial) {
    final start = before.length - partial.length;
    if (start <= 0 || before[start - 1] != '.') {
      return null;
    }
    return RegExp(
      r'[A-Za-z_]\w*$',
    ).firstMatch(before.substring(0, start - 1))?.group(0);
  }

  /// Finds the clause the cursor sits in by scanning back to the nearest clause
  /// keyword (ignoring the partial word abutting the cursor).
  static _Clause _clauseKeyword(String before, {required bool hasPartial}) {
    final tokens = SqlTokenizer.tokenize(before);
    var end = tokens.length;
    if (hasPartial && end > 0 && tokens[end - 1].end == before.length) {
      end--; // drop the word currently being typed
    }
    for (var i = end - 1; i >= 0; i--) {
      final word = tokens[i].lower;
      if (_tableClauseKeywords.contains(word)) return _Clause.table;
      if (_columnClauseKeywords.contains(word)) return _Clause.column;
    }
    return _Clause.statementStart;
  }

  /// Extracts referenced tables and alias→table bindings from `FROM`/`JOIN`
  /// clauses across the whole [line] (so columns are offered even when the
  /// cursor is in the SELECT list before the FROM).
  static _References _references(String line) {
    final tokens = SqlTokenizer.tokenize(line);
    final tables = <String>[];
    final aliases = <String, String>{};

    for (var i = 0; i < tokens.length; i++) {
      final word = tokens[i].lower;
      if (word != 'from' &&
          word != 'join' &&
          word != 'into' &&
          word != 'update') {
        continue;
      }
      final j = i + 1;
      if (j >= tokens.length || _allKeywords.contains(tokens[j].lower)) {
        continue;
      }
      // Resolve schema-qualified names (schema.table) to the trailing part.
      var tableToken = tokens[j];
      var k = j + 1;
      while (k < tokens.length && tokens[k].precededByDot) {
        tableToken = tokens[k];
        k++;
      }
      final tableName = tableToken.text;
      tables.add(tableName);

      // Optional alias: `[AS] alias`.
      var a = k;
      if (a < tokens.length && tokens[a].lower == 'as') a++;
      if (a < tokens.length &&
          !_allKeywords.contains(tokens[a].lower) &&
          !tokens[a].precededByDot) {
        aliases[tokens[a].lower] = tableName;
      }
    }
    return _References(tables, aliases);
  }

  static const Set<String> _tableClauseKeywords = <String>{
    'from',
    'join',
    'into',
    'update',
    'table',
  };

  static const Set<String> _columnClauseKeywords = <String>{
    'select',
    'where',
    'on',
    'having',
    'set',
    'by',
    'returning',
    'using',
  };

  /// Keywords offered as a fallback / in column clauses. Inserted upper-cased.
  static const List<String> _keywords = <String>[
    'SELECT',
    'FROM',
    'WHERE',
    'JOIN',
    'LEFT',
    'RIGHT',
    'INNER',
    'OUTER',
    'FULL',
    'ON',
    'AS',
    'AND',
    'OR',
    'NOT',
    'IN',
    'IS',
    'NULL',
    'LIKE',
    'ILIKE',
    'BETWEEN',
    'GROUP',
    'ORDER',
    'BY',
    'HAVING',
    'LIMIT',
    'OFFSET',
    'DISTINCT',
    'ASC',
    'DESC',
    'UNION',
    'WITH',
    'CASE',
    'WHEN',
    'THEN',
    'ELSE',
    'END',
    'COUNT',
    'SUM',
    'AVG',
    'MIN',
    'MAX',
    'COALESCE',
  ];

  static final Set<String> _allKeywords = _keywords
      .map((keyword) => keyword.toLowerCase())
      .toSet();
}

enum _Clause { table, column, statementStart }

class _References {
  const _References(this.tables, this.aliases);

  final List<String> tables;
  final Map<String, String> aliases;
}
