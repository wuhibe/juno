import 'package:flutter/material.dart';

import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/app_typography.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/db/adapter/models/column_meta.dart';
import 'package:juno/db/adapter/models/query_result.dart';

/// A scrollable tabular view of a [QueryResult].
///
/// Deliberately simple for the schema-browser preview: header + cells, NULL
/// rendered as a muted italic `NULL` (never an empty string). Phase 5 replaces
/// this with the full trina_grid (sort, pagination, cell viewer).
class QueryResultView extends StatelessWidget {
  /// Creates a results view for [result].
  const QueryResultView({required this.result, super.key});

  /// The result to render.
  final QueryResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;

    if (result.columns.isEmpty) {
      return Center(
        child: Text(
          result.affectedRows > 0
              ? '${result.affectedRows} row(s) affected'
              : 'No columns returned',
          style: theme.textTheme.bodyMedium?.copyWith(color: colors.textMuted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll<Color>(
                  colors.surfaceAlt,
                ),
                dividerThickness: 1,
                columns: <DataColumn>[
                  for (final column in result.columns)
                    DataColumn(label: _HeaderCell(column: column)),
                ],
                rows: <DataRow>[
                  for (final row in result.rows)
                    DataRow(
                      cells: <DataCell>[
                        for (final value in row) DataCell(_ValueCell(value)),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        _ResultFooter(result: result),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.column});

  final ColumnMeta column;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          column.name,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          column.dbType,
          style: AppTypography.mono(10, color: colors.textFaint),
        ),
      ],
    );
  }
}

class _ValueCell extends StatelessWidget {
  const _ValueCell(this.value);

  final Object? value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    if (value == null) {
      return Text(
        'NULL',
        style: AppTypography.mono(
          12,
          color: colors.textFaint,
        ).copyWith(fontStyle: FontStyle.italic),
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Text(
        '$value',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.mono(12, color: colors.textPrimary),
      ),
    );
  }
}

class _ResultFooter extends StatelessWidget {
  const _ResultFooter({required this.result});

  final QueryResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: <Widget>[
          Text(
            '${result.rowCount} rows',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.textMuted,
            ),
          ),
          const Spacer(),
          Text(
            '${result.elapsed.inMilliseconds} ms',
            style: AppTypography.mono(11, color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}
