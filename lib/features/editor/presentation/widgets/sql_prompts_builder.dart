import 'package:flutter/widgets.dart';
import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:juno/features/editor/domain/sql_autocomplete_engine.dart';
import 'package:juno/features/editor/domain/sql_schema_snapshot.dart';
import 'package:juno/features/editor/domain/sql_suggestion.dart';
import 'package:re_editor/re_editor.dart';

/// A [CodePrompt] carrying a Juno [SqlSuggestion] so the dropdown view can
/// render it with the right category color and detail line.
class SqlCodePrompt extends CodePrompt {
  /// Wraps [suggestion] as a re_editor prompt.
  SqlCodePrompt(this.suggestion) : super(word: suggestion.label);

  /// The underlying suggestion.
  final SqlSuggestion suggestion;

  @override
  CodeAutocompleteResult get autocomplete =>
      CodeAutocompleteResult.fromWord(suggestion.insertText);

  // The engine already produced a filtered, ranked list, so every prompt is a
  // match — re_editor only re-checks this for its own default builder.
  @override
  bool match(String input) => true;
}

/// Bridges [SqlAutocompleteEngine] into re_editor's autocomplete hook.
///
/// On each keystroke re_editor calls [build] with the current line and cursor.
/// We assemble a [SqlSchemaSnapshot] from the eagerly-loaded [tables] plus the
/// columns of whatever tables the statement references (resolved synchronously
/// from cache via [resolveColumns]), then run the engine.
class SqlPromptsBuilder implements CodeAutocompletePromptsBuilder {
  /// Creates a builder over [tables] with a synchronous column [resolveColumns]
  /// lookup.
  const SqlPromptsBuilder({required this.tables, required this.resolveColumns});

  /// All tables across visible schemas.
  final List<DbTable> tables;

  /// Returns the cached columns for a bare table name (and may warm the cache
  /// for next time); returns empty when not yet loaded.
  final List<DbColumn> Function(String tableName) resolveColumns;

  @override
  CodeAutocompleteEditingValue? build(
    BuildContext context,
    CodeLine codeLine,
    CodeLineSelection selection,
  ) {
    final line = codeLine.text;
    final cursor = selection.extentOffset.clamp(0, line.length);
    final before = line.substring(0, cursor);
    final input = RegExp(r'[A-Za-z_]\w*$').firstMatch(before)?.group(0) ?? '';

    final columnsByTable = <String, List<DbColumn>>{};
    for (final name in SqlAutocompleteEngine.referencedTableNames(line)) {
      columnsByTable[name.toLowerCase()] = resolveColumns(name);
    }

    final engine = SqlAutocompleteEngine(
      SqlSchemaSnapshot(tables: tables, columnsByTable: columnsByTable),
    );
    final suggestions = engine.suggest(line, cursor);
    if (suggestions.isEmpty) {
      return null;
    }

    return CodeAutocompleteEditingValue(
      input: input,
      prompts: suggestions.map(SqlCodePrompt.new).toList(),
      index: 0,
    );
  }
}
