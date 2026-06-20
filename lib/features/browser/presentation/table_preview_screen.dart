import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:juno/core/errors/app_exception.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/app_typography.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/features/browser/application/table_preview_provider.dart';
import 'package:juno/features/results/presentation/query_result_view.dart';

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
        data: (result) => QueryResultView(result: result),
      ),
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
