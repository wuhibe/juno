import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/app_typography.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/features/results/domain/cell_formatter.dart';

/// A bottom sheet showing a single cell's full value, with copy and (for
/// JSON-like values) pretty-printing.
class CellViewerSheet extends StatelessWidget {
  /// Creates the viewer for [column]'s [value].
  const CellViewerSheet({required this.column, required this.value, super.key});

  /// The column name (sheet title).
  final String column;

  /// The raw cell value.
  final Object? value;

  /// Shows the sheet.
  static Future<void> show(
    BuildContext context, {
    required String column,
    required Object? value,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CellViewerSheet(column: column, value: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;
    final isNull = value == null;
    final pretty = prettyJson(value);
    final display = pretty ?? formatCellValue(value);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    column,
                    style: AppTypography.mono(15, weight: FontWeight.w600),
                  ),
                ),
                if (pretty != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: Text(
                      'JSON',
                      style: AppTypography.mono(10, color: colors.value),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  tooltip: 'Copy',
                  onPressed: isNull
                      ? null
                      : () async {
                          await Clipboard.setData(ClipboardData(text: display));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied')),
                            );
                          }
                        },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 360),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.canvas,
                  borderRadius: AppRadii.mdAll,
                  border: Border.all(color: colors.border),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    isNull ? 'NULL' : display,
                    style:
                        AppTypography.mono(
                          12.5,
                          color: isNull ? colors.textFaint : colors.textPrimary,
                        ).copyWith(
                          fontStyle: isNull
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
