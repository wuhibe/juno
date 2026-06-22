import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juno/core/errors/app_exception.dart';
import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/app_typography.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/data/data_providers.dart';
import 'package:juno/features/editor/application/query_runner_provider.dart';
import 'package:juno/features/editor/domain/sql_statement.dart';
import 'package:juno/features/editor/presentation/widgets/snippet_toolbar.dart';
import 'package:juno/features/editor/presentation/widgets/sql_code_field.dart';
import 'package:juno/features/editor/presentation/widgets/write_warning_dialog.dart';
import 'package:juno/features/results/presentation/cell_viewer_sheet.dart';
import 'package:juno/features/results/presentation/results_grid.dart';
import 'package:re_editor/re_editor.dart';

/// The SQL editor: write a query, run/cancel it, and browse paged results.
class EditorScreen extends ConsumerStatefulWidget {
  /// Creates the editor bound to [connectionId] (for the read-only badge).
  const EditorScreen({required this.connectionId, super.key});

  /// The active connection's id.
  final String connectionId;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final CodeLineEditingController _controller = CodeLineEditingController();
  final FocusNode _editorFocus = FocusNode();

  @override
  void dispose() {
    _editorFocus.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final sql = _controller.text;
    // Layer 2 (UX): warn before letting the server reject a write on a
    // read-only connection (plan §4). The server is still the guarantee.
    if (_readOnly(listen: false)) {
      final statement = SqlStatement.classify(sql);
      if (statement.kind == StatementKind.write ||
          statement.kind == StatementKind.ddl) {
        final runAnyway = await WriteWarningDialog.show(
          context,
          keyword: statement.firstKeyword.toUpperCase(),
        );
        if (!runAnyway) {
          return;
        }
      }
    }
    if (!mounted) {
      return;
    }
    await ref.read(queryRunnerProvider.notifier).run(sql);
  }

  void _cancel() => ref.read(queryRunnerProvider.notifier).cancel();

  /// Whether the active connection is read-only. Pass [listen] `true` from
  /// `build` (to rebuild the badge) and `false` from callbacks.
  bool _readOnly({required bool listen}) {
    final connections = listen
        ? ref.watch(connectionsListProvider).value
        : ref.read(connectionsListProvider).value;
    if (connections == null) {
      return false;
    }
    for (final connection in connections) {
      if (connection.id == widget.connectionId) {
        return connection.readOnly;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    final state = ref.watch(queryRunnerProvider);
    final running = state is QueryRunning;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL editor'),
        actions: <Widget>[
          if (_readOnly(listen: true))
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: colors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    'read-only',
                    style: AppTypography.mono(11, color: colors.textMuted),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(bottom: BorderSide(color: colors.border)),
              ),
              child: SqlCodeField(
                controller: _controller,
                focusNode: _editorFocus,
              ),
            ),
          ),
          _Toolbar(running: running, onRun: _run, onCancel: _cancel),
          Expanded(flex: 3, child: _ResultsArea(state: state)),
          // Always mounted (even while unfocused) so it survives modal sheets
          // like the FROM table picker, which transiently steal focus.
          SnippetToolbar(
            controller: _controller,
            focusNode: _editorFocus,
            isReadOnly: _readOnly(listen: true),
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.running,
    required this.onRun,
    required this.onCancel,
  });

  final bool running;
  final VoidCallback onRun;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: colors.surfaceAlt,
      child: Row(
        children: <Widget>[
          FilledButton.icon(
            onPressed: running ? null : onRun,
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Run'),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (running)
            OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.stop_rounded, size: 18),
              label: const Text('Cancel'),
            ),
        ],
      ),
    );
  }
}

class _ResultsArea extends ConsumerWidget {
  const _ResultsArea({required this.state});

  final QueryRunState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.juno;

    return switch (state) {
      QueryRunIdle() => Center(
        child: Text(
          'Run a query to see results.',
          style: theme.textTheme.bodyMedium?.copyWith(color: colors.textMuted),
        ),
      ),
      QueryRunning() => const Center(child: CircularProgressIndicator()),
      QueryRunFailure(:final error) => _ErrorPanel(error: error),
      final QueryRunSuccess success => _SuccessView(success: success),
    };
  }
}

class _SuccessView extends ConsumerWidget {
  const _SuccessView({required this.success});

  final QueryRunSuccess success;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.juno;

    if (success.columns.isEmpty) {
      return Center(
        child: Text(
          '${success.affectedRows} row(s) affected · '
          '${success.elapsed.inMilliseconds} ms',
          style: theme.textTheme.bodyMedium?.copyWith(color: colors.textMuted),
        ),
      );
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: ResultsGrid(
            key: ValueKey<int>(success.queryId),
            columns: success.columns,
            rows: success.rows,
            onViewCell: (column, value) =>
                CellViewerSheet.show(context, column: column, value: value),
          ),
        ),
        _ResultFooter(success: success),
      ],
    );
  }
}

class _ResultFooter extends ConsumerWidget {
  const _ResultFooter({required this.success});

  final QueryRunSuccess success;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            '${success.rows.length} rows'
            '${success.canLoadMore ? '+' : ''}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.textMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            '${success.elapsed.inMilliseconds} ms',
            style: AppTypography.mono(11, color: colors.textMuted),
          ),
          const Spacer(),
          if (success.canLoadMore)
            TextButton(
              onPressed: success.loadingMore
                  ? null
                  : () => ref.read(queryRunnerProvider.notifier).loadMore(),
              child: success.loadingMore
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Load more'),
            ),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.error});

  final AppException error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;
    final position = error is QueryException
        ? (error as QueryException).position
        : null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: 0.1),
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: colors.danger.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.error_outline_rounded, size: 18, color: colors.danger),
              const SizedBox(width: AppSpacing.sm),
              Text(
                error is QueryCancelledException ? 'Cancelled' : 'Query error',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.danger,
                ),
              ),
              if (position != null) ...<Widget>[
                const Spacer(),
                Text(
                  'at position $position',
                  style: AppTypography.mono(11, color: colors.danger),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(error.message, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
