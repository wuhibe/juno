import 'package:juno/features/editor/domain/sql_tokenizer.dart';

/// What the cursor most recently followed — drives how the snippet toolbar
/// reorders its chip groups ("context awareness").
enum EditorContext {
  /// Empty buffer or just after `;`.
  statementStart,

  /// Right after `SELECT`.
  afterSelect,

  /// Right after `FROM` / `JOIN`.
  afterFrom,

  /// In a `WHERE` / `AND` / `OR` / `ON` predicate.
  afterWhere,

  /// Right after a comparison operator (`=`, `LIKE`, `IN`, …).
  afterOperator,

  /// Right after `ORDER BY` / `GROUP BY`.
  afterOrderBy,

  /// Right after a table reference.
  afterTable,

  /// Anything else.
  general,
}

/// A re-orderable group of chips in the toolbar.
enum SnippetGroup {
  /// Dynamic table chips.
  tables,

  /// Dynamic column chips for the active table.
  columns,

  /// Structure category.
  structure,

  /// Operators category.
  operators,

  /// Values category.
  value,
}

/// Maps editor text to a context and an ordering of chip groups.
abstract final class SnippetContext {
  /// Classifies the cursor position from the text [before] it.
  static EditorContext analyze(String before) {
    final trimmed = before.trimRight();
    if (trimmed.isEmpty || trimmed.endsWith(';')) {
      return EditorContext.statementStart;
    }
    // A bare comparison operator just before the cursor.
    final lastCh = trimmed[trimmed.length - 1];
    if (lastCh == '=' || lastCh == '<' || lastCh == '>' || lastCh == '!') {
      return EditorContext.afterOperator;
    }

    final tokens = SqlTokenizer.tokenize(before);
    if (tokens.isEmpty) {
      return EditorContext.general;
    }
    final last = tokens.last.lower;
    final prev = tokens.length >= 2 ? tokens[tokens.length - 2].lower : '';

    if ((prev == 'order' || prev == 'group') && last == 'by') {
      return EditorContext.afterOrderBy;
    }
    if (last == 'select') {
      return EditorContext.afterSelect;
    }
    if (last == 'from' || last == 'join') {
      return EditorContext.afterFrom;
    }
    if (_predicateKeywords.contains(last)) {
      return EditorContext.afterWhere;
    }
    if (_operatorKeywords.contains(last)) {
      return EditorContext.afterOperator;
    }
    if (!_keywords.contains(last)) {
      // A trailing identifier — most often a table/column reference.
      return EditorContext.afterTable;
    }
    return EditorContext.general;
  }

  /// The chip-group order for [context]. Empty groups are skipped by the
  /// toolbar; the full set is always reachable by scrolling.
  static List<SnippetGroup> orderGroups(EditorContext context) {
    return switch (context) {
      EditorContext.statementStart => const <SnippetGroup>[
        SnippetGroup.structure,
        SnippetGroup.value,
        SnippetGroup.operators,
        SnippetGroup.tables,
        SnippetGroup.columns,
      ],
      EditorContext.afterSelect => const <SnippetGroup>[
        SnippetGroup.columns,
        SnippetGroup.value,
        SnippetGroup.structure,
        SnippetGroup.tables,
        SnippetGroup.operators,
      ],
      EditorContext.afterFrom => const <SnippetGroup>[
        SnippetGroup.tables,
        SnippetGroup.structure,
        SnippetGroup.columns,
        SnippetGroup.operators,
        SnippetGroup.value,
      ],
      EditorContext.afterWhere => const <SnippetGroup>[
        SnippetGroup.columns,
        SnippetGroup.operators,
        SnippetGroup.value,
        SnippetGroup.structure,
        SnippetGroup.tables,
      ],
      EditorContext.afterOperator => const <SnippetGroup>[
        SnippetGroup.value,
        SnippetGroup.columns,
        SnippetGroup.operators,
        SnippetGroup.structure,
        SnippetGroup.tables,
      ],
      EditorContext.afterOrderBy => const <SnippetGroup>[
        SnippetGroup.columns,
        SnippetGroup.structure,
        SnippetGroup.operators,
        SnippetGroup.value,
        SnippetGroup.tables,
      ],
      EditorContext.afterTable => const <SnippetGroup>[
        SnippetGroup.structure,
        SnippetGroup.columns,
        SnippetGroup.operators,
        SnippetGroup.value,
        SnippetGroup.tables,
      ],
      EditorContext.general => const <SnippetGroup>[
        SnippetGroup.structure,
        SnippetGroup.operators,
        SnippetGroup.value,
        SnippetGroup.tables,
        SnippetGroup.columns,
      ],
    };
  }

  static const Set<String> _predicateKeywords = <String>{
    'where',
    'and',
    'or',
    'on',
    'having',
  };

  static const Set<String> _operatorKeywords = <String>{
    'like',
    'ilike',
    'between',
    'in',
    'not',
    'is',
  };

  static const Set<String> _keywords = <String>{
    'select',
    'from',
    'where',
    'join',
    'left',
    'right',
    'inner',
    'outer',
    'full',
    'on',
    'as',
    'and',
    'or',
    'not',
    'in',
    'is',
    'null',
    'like',
    'ilike',
    'between',
    'group',
    'order',
    'by',
    'having',
    'limit',
    'offset',
    'distinct',
    'asc',
    'desc',
    'union',
    'with',
    'insert',
    'into',
    'update',
    'delete',
    'set',
    'values',
  };
}
