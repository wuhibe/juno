import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:juno/features/browser/application/schema_cache_provider.dart';
import 'package:juno/features/editor/application/autocomplete_index_provider.dart';
import 'package:juno/features/editor/presentation/widgets/sql_autocomplete_view.dart';
import 'package:juno/features/editor/presentation/widgets/sql_prompts_builder.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/sql.dart';

/// The SQL editing surface: `re_editor` with a syntax-highlight theme whose
/// hues match the snippet/semantic palette (keywords violet, strings/numbers
/// teal, operators amber) so code and chips read as one system — plus
/// schema-aware autocomplete (keywords → tables → columns).
class SqlCodeField extends ConsumerStatefulWidget {
  /// Creates the field bound to [controller].
  const SqlCodeField({required this.controller, super.key});

  /// The editing controller (owns the SQL text).
  final CodeLineEditingController controller;

  @override
  ConsumerState<SqlCodeField> createState() => _SqlCodeFieldState();
}

class _SqlCodeFieldState extends ConsumerState<SqlCodeField> {
  /// Returns cached columns for a bare table name, warming the cache (lazily,
  /// for next keystroke) when this table has not been introspected yet.
  List<DbColumn> _resolveColumns(Map<String, DbTable> byName, String name) {
    final table = byName[name.toLowerCase()];
    if (table == null) {
      return const <DbColumn>[];
    }
    final async = ref.read(columnListProvider(table.schema, table.name));
    final columns = async.value;
    if (columns != null) {
      return columns;
    }
    // Not loaded yet — kick off the load so it's ready next time.
    unawaited(ref.read(columnListProvider(table.schema, table.name).future));
    return const <DbColumn>[];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    final monoFamily = GoogleFonts.getFont('JetBrains Mono').fontFamily;
    final tables =
        ref.watch(autocompleteTablesProvider).value ?? const <DbTable>[];
    final byName = <String, DbTable>{
      for (final table in tables) table.name.toLowerCase(): table,
    };

    return CodeAutocomplete(
      viewBuilder: (context, notifier, onSelected) => SqlAutocompleteView(
        notifier: notifier,
        onSelected: onSelected,
        colors: colors,
      ),
      promptsBuilder: SqlPromptsBuilder(
        tables: tables,
        resolveColumns: (name) => _resolveColumns(byName, name),
      ),
      child: CodeEditor(
        controller: widget.controller,
        wordWrap: false,
        autofocus: false,
        hint: 'SELECT * FROM …',
        padding: const EdgeInsets.all(12),
        style: CodeEditorStyle(
          fontSize: 14,
          fontFamily: monoFamily,
          fontFamilyFallback: const <String>['monospace'],
          textColor: colors.textPrimary,
          hintTextColor: colors.textFaint,
          backgroundColor: colors.surface,
          cursorColor: colors.accent,
          selectionColor: colors.accent.withValues(alpha: 0.3),
          codeTheme: CodeHighlightTheme(
            languages: <String, CodeHighlightThemeMode>{
              'sql': CodeHighlightThemeMode(mode: langSql),
            },
            theme: _highlightTheme(colors),
          ),
        ),
      ),
    );
  }

  Map<String, TextStyle> _highlightTheme(JunoColors colors) {
    return <String, TextStyle>{
      'root': TextStyle(color: colors.textPrimary),
      'keyword': TextStyle(color: colors.keyword, fontWeight: FontWeight.w600),
      'built_in': TextStyle(color: colors.keyword),
      'type': TextStyle(color: colors.schema),
      'literal': TextStyle(color: colors.operator),
      'number': TextStyle(color: colors.value),
      'string': TextStyle(color: colors.value),
      'operator': TextStyle(color: colors.operator),
      'punctuation': TextStyle(color: colors.textMuted),
      'comment': TextStyle(
        color: colors.textFaint,
        fontStyle: FontStyle.italic,
      ),
      'variable': TextStyle(color: colors.schema),
      'attr': TextStyle(color: colors.schema),
    };
  }
}
