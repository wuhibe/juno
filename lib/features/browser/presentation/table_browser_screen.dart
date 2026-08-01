import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:juno/core/errors/app_exception.dart';
import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/app_typography.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/db/adapter/models/table_query.dart';
import 'package:juno/features/browser/application/schema_cache_provider.dart';
import 'package:juno/features/browser/application/table_browse_provider.dart';
import 'package:juno/features/browser/presentation/widgets/column_filter_sheet.dart';
import 'package:juno/features/results/presentation/cell_viewer_sheet.dart';
import 'package:juno/features/results/presentation/results_grid.dart';

/// Schema + table identifying a browse target, passed via go_router `extra`.
class TableBrowserArgs {
  /// Creates browse arguments.
  const TableBrowserArgs({required this.schema, required this.table});

  /// The owning schema.
  final String schema;

  /// The table/view name.
  final String table;
}

/// Browses one table: filter, sort, and page through it server-side.
class TableBrowserScreen extends ConsumerWidget {
  /// Creates the browser screen.
  const TableBrowserScreen({required this.args, super.key});

  /// The schema/table to browse.
  final TableBrowserArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = tableBrowseProvider(args.schema, args.table);
    final state = ref.watch(provider);
    final browse = ref.read(provider.notifier);
    final colors = Theme.of(context).juno;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${args.schema}.${args.table}',
          style: AppTypography.mono(15, weight: FontWeight.w600),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Add filter',
            icon: Icon(Icons.filter_alt_outlined, color: colors.schema),
            onPressed: () => _addFilter(context, ref),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (state.filters.isNotEmpty)
            _FilterChips(
              filters: state.filters,
              onRemove: browse.removeFilterAt,
              onClear: () => browse.applyFilters(const <ColumnFilter>[]),
            ),
          Expanded(child: _body(context, state, browse)),
          _Footer(state: state, onLoadMore: browse.loadMore),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    TableBrowseState state,
    TableBrowse browse,
  ) {
    final error = state.error;
    if (error != null) {
      return _BrowseError(error: error, onRetry: browse.refresh);
    }
    if (state.loading && state.rows.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.columns.isEmpty) {
      return _emptyMessage(context, 'No columns returned');
    }
    if (state.rows.isEmpty) {
      return _emptyMessage(
        context,
        state.filters.isEmpty ? 'This table is empty' : 'No matching rows',
      );
    }

    return ResultsGrid(
      key: ValueKey<int>(state.queryId),
      columns: state.columns,
      rows: state.rows,
      onSort: browse.sortBy,
      onViewCell: (column, value) =>
          CellViewerSheet.show(context, column: column, value: value),
    );
  }

  Widget _emptyMessage(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.juno.textMuted,
        ),
      ),
    );
  }

  Future<void> _addFilter(BuildContext context, WidgetRef ref) async {
    final columns = await ref.read(
      columnListProvider(args.schema, args.table).future,
    );
    if (!context.mounted || columns.isEmpty) {
      return;
    }
    final filter = await ColumnFilterSheet.show(context, columns: columns);
    if (filter == null) {
      return;
    }
    final provider = tableBrowseProvider(args.schema, args.table);
    final current = ref.read(provider).filters;
    ref.read(provider.notifier).applyFilters(<ColumnFilter>[
      ...current,
      filter,
    ]);
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filters,
    required this.onRemove,
    required this.onClear,
  });

  final List<ColumnFilter> filters;
  final void Function(int index) onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          for (var i = 0; i < filters.length; i++)
            Chip(
              label: Text(
                filters[i].label,
                style: AppTypography.mono(12, color: colors.schema),
              ),
              backgroundColor: colors.schema.withValues(alpha: 0.18),
              side: BorderSide(color: colors.schema),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              deleteIconColor: colors.schema,
              onDeleted: () => onRemove(i),
            ),
          TextButton(onPressed: onClear, child: const Text('Clear all')),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.onLoadMore});

  final TableBrowseState state;
  final Future<void> Function() onLoadMore;

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
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Text(
              '${state.rows.length} rows${state.canLoadMore ? '+' : ''}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.textMuted,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '${state.elapsed.inMilliseconds} ms',
              style: AppTypography.mono(11, color: colors.textMuted),
            ),
            const Spacer(),
            if (state.canLoadMore)
              TextButton(
                onPressed: state.loadingMore ? null : onLoadMore,
                child: state.loadingMore
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Load more'),
              ),
          ],
        ),
      ),
    );
  }
}

class _BrowseError extends StatelessWidget {
  const _BrowseError({required this.error, required this.onRetry});

  final AppException error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.error_outline_rounded, color: colors.danger, size: 36),
            const SizedBox(height: AppSpacing.lg),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
