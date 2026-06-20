import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:juno/core/errors/app_exception.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/app_typography.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/db/adapter/models/query_result.dart';
import 'package:juno/features/browser/application/table_preview_provider.dart';
import 'package:juno/features/results/presentation/cell_viewer_sheet.dart';
import 'package:juno/features/results/presentation/results_grid.dart';

/// Schema + table identifying a preview target, passed via go_router `extra`.
class TablePreviewArgs {
  /// Creates preview arguments.
  const TablePreviewArgs({required this.schema, required this.table});

  /// The owning schema.
  final String schema;

  /// The table/view name.
  final String table;
}

/// Shows the first [tablePreviewLimit] rows of a table through the results view.
class TablePreviewScreen extends ConsumerWidget {
  /// Creates the preview screen.
  const TablePreviewScreen({required this.args, super.key});

  /// The schema/table to preview.
  final TablePreviewArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewAsync = ref.watch(
      tablePreviewProvider(args.schema, args.table),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${args.schema}.${args.table}',
          style: AppTypography.mono(15, weight: FontWeight.w600),
        ),
      ),
      body: previewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _PreviewError(error: error),
        data: (result) => _PreviewBody(result: result),
      ),
    );
  }
}

class _PreviewBody extends StatelessWidget {
  const _PreviewBody({required this.result});

  final QueryResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;

    if (result.columns.isEmpty) {
      return Center(
        child: Text(
          'No columns returned',
          style: theme.textTheme.bodyMedium?.copyWith(color: colors.textMuted),
        ),
      );
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: ResultsGrid(
            columns: result.columns,
            rows: result.rows,
            onViewCell: (column, value) =>
                CellViewerSheet.show(context, column: column, value: value),
          ),
        ),
        Container(
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
                '${result.rowCount} rows (preview)',
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
        ),
      ],
    );
  }
}

class _PreviewError extends StatelessWidget {
  const _PreviewError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;
    final message = error is AppException
        ? (error as AppException).message
        : '$error';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.error_outline_rounded, color: colors.danger, size: 36),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
