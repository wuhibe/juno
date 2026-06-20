import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/sql.dart';

/// The SQL editing surface: `re_editor` with a syntax-highlight theme whose
/// hues match the snippet/semantic palette (keywords violet, strings/numbers
/// teal, operators amber) so code and chips read as one system.
class SqlCodeField extends StatelessWidget {
  /// Creates the field bound to [controller].
  const SqlCodeField({required this.controller, super.key});

  /// The editing controller (owns the SQL text).
  final CodeLineEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    final monoFamily = GoogleFonts.getFont('JetBrains Mono').fontFamily;

    return CodeEditor(
      controller: controller,
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
