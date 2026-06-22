import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/app_typography.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/data/data_providers.dart';
import 'package:juno/data/models/query_history_entry.dart';
import 'package:juno/features/editor/application/editor_draft_provider.dart';
import 'package:juno/features/history/application/query_history_provider.dart';

/// The per-connection query history (plan §8.1): re-run, copy, or insert any
/// past statement back into the editor.
class QueryHistoryScreen extends ConsumerWidget {
  /// Creates the history screen for [connectionId].
  const QueryHistoryScreen({required this.connectionId, super.key});

  /// The connection whose history is shown.
  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(queryHistoryProvider(connectionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Query history'),
        actions: <Widget>[
          entriesAsync.maybeWhen(
            data: (entries) => entries.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    tooltip: 'Clear history',
                    onPressed: () => _confirmClear(context, ref),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (entries) {
          if (entries.isEmpty) {
            return const _EmptyHistory();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: entries.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) =>
                _HistoryTile(entry: entries[index]),
          );
        },
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text(
          'All saved queries for this connection will be removed.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).juno.danger,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref
          .read(queryHistoryRepositoryProvider)
          .clearForConnection(connectionId);
    }
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.entry});

  final QueryHistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.juno;
    final accent = entry.success ? colors.success : colors.danger;

    return InkWell(
      borderRadius: AppRadii.lgAll,
      onTap: () => _showActions(context, ref),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadii.lgAll,
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  entry.success
                      ? Icons.check_circle_outline_rounded
                      : Icons.error_outline_rounded,
                  size: 16,
                  color: accent,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _formatTime(entry.startedAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ),
                Text(
                  '${entry.elapsedMs} ms',
                  style: AppTypography.mono(11, color: colors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              entry.sqlText.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.mono(13, color: colors.textPrimary),
            ),
            if (!entry.success && entry.errorSummary != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                entry.errorSummary!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.danger,
                ),
              ),
            ] else if (entry.rowCount != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${entry.rowCount} row(s)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).juno.surface,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.play_arrow_rounded),
              title: const Text('Re-run'),
              onTap: () {
                ref
                    .read(editorDraftRequestProvider.notifier)
                    .load(entry.sqlText, run: true);
                Navigator.of(sheetContext).pop();
                context.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note_rounded),
              title: const Text('Insert into editor'),
              onTap: () {
                ref
                    .read(editorDraftRequestProvider.notifier)
                    .load(entry.sqlText);
                Navigator.of(sheetContext).pop();
                context.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Copy SQL'),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: entry.sqlText));
                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final isToday =
        now.year == time.year && now.month == time.month && now.day == time.day;
    return isToday
        ? DateFormat.jms().format(time)
        : DateFormat.yMMMd().add_jm().format(time);
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

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
            Icon(Icons.history_rounded, size: 48, color: colors.textFaint),
            const SizedBox(height: AppSpacing.lg),
            Text('No queries yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Statements you run in the editor show up here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
