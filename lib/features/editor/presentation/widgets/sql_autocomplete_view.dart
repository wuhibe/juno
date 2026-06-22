import 'package:flutter/material.dart';
import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/app_typography.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/features/editor/domain/sql_suggestion.dart';
import 'package:juno/features/editor/presentation/widgets/sql_prompts_builder.dart';
import 'package:re_editor/re_editor.dart';

/// The autocomplete dropdown: a compact, token-themed list whose rows are
/// colored by suggestion category (keywords violet, tables/columns green) so it
/// reads as one system with the editor's highlighting and the snippet chips.
class SqlAutocompleteView extends StatelessWidget
    implements PreferredSizeWidget {
  /// Creates the dropdown bound to re_editor's [notifier] and [onSelected].
  const SqlAutocompleteView({
    required this.notifier,
    required this.onSelected,
    required this.colors,
    super.key,
  });

  /// The current input + matched prompts + selected index.
  final ValueNotifier<CodeAutocompleteEditingValue> notifier;

  /// Applies the chosen suggestion to the editor.
  final ValueChanged<CodeAutocompleteResult> onSelected;

  /// Resolved theme tokens (the overlay sits outside the editor's subtree).
  final JunoColors colors;

  static const double _rowHeight = 36;
  static const double _width = 280;
  static const int _maxVisibleRows = 6;

  int get _rowCount => notifier.value.prompts.length;

  @override
  Size get preferredSize {
    final rows = _rowCount.clamp(1, _maxVisibleRows);
    return Size(_width, rows * _rowHeight + AppSpacing.xs * 2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: colors.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.canvas.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ValueListenableBuilder<CodeAutocompleteEditingValue>(
        valueListenable: notifier,
        builder: (context, value, _) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            shrinkWrap: true,
            itemCount: value.prompts.length,
            itemBuilder: (context, index) {
              final prompt = value.prompts[index];
              return _SuggestionRow(
                suggestion: prompt is SqlCodePrompt
                    ? prompt.suggestion
                    : SqlSuggestion(
                        label: prompt.word,
                        insertText: prompt.word,
                        kind: SqlSuggestionKind.keyword,
                      ),
                selected: index == value.index,
                colors: colors,
                onTap: () =>
                    onSelected(value.copyWith(index: index).autocomplete),
              );
            },
          );
        },
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({
    required this.suggestion,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final SqlSuggestion suggestion;
  final bool selected;
  final JunoColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _accent(suggestion.kind, colors);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: SqlAutocompleteView._rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        color: selected ? accent.withValues(alpha: 0.16) : null,
        child: Row(
          children: <Widget>[
            Icon(_icon(suggestion.kind), size: 14, color: accent),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                suggestion.label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.mono(13, color: colors.textPrimary),
              ),
            ),
            if (suggestion.detail != null) ...<Widget>[
              const SizedBox(width: AppSpacing.sm),
              Text(
                suggestion.detail!,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.mono(10, color: colors.textFaint),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Color _accent(SqlSuggestionKind kind, JunoColors colors) {
    return switch (kind) {
      SqlSuggestionKind.keyword => colors.keyword,
      SqlSuggestionKind.table => colors.schema,
      SqlSuggestionKind.column => colors.schema,
    };
  }

  static IconData _icon(SqlSuggestionKind kind) {
    return switch (kind) {
      SqlSuggestionKind.keyword => Icons.code_rounded,
      SqlSuggestionKind.table => Icons.table_chart_outlined,
      SqlSuggestionKind.column => Icons.view_column_outlined,
    };
  }
}
