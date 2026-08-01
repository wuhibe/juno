import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:juno/core/errors/app_exception.dart';
import 'package:juno/core/router/app_router.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/app_typography.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:juno/features/browser/application/schema_cache_provider.dart';
import 'package:juno/features/browser/presentation/table_browser_screen.dart';

/// The collapsible schema → tables → columns tree.
///
/// Each level loads lazily on expand (via the keep-alive cache providers) and
/// pull-to-refresh re-introspects the database.
class SchemaBrowser extends ConsumerWidget {
  /// Creates the browser for [connectionId] (used to route to table browsing).
  const SchemaBrowser({required this.connectionId, super.key});

  /// The active connection's id.
  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemasAsync = ref.watch(schemaListProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref
          ..invalidate(schemaListProvider)
          ..invalidate(tableListProvider)
          ..invalidate(columnListProvider);
        await ref.read(schemaListProvider.future);
      },
      child: schemasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _NodeError(error: error, padded: true),
        data: (schemas) {
          if (schemas.isEmpty) {
            return _emptyHint(context);
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: schemas.length,
            itemBuilder: (context, index) =>
                _SchemaNode(schema: schemas[index], connectionId: connectionId),
          );
        },
      ),
    );
  }

  Widget _emptyHint(BuildContext context) {
    final colors = Theme.of(context).juno;
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Center(
            child: Text(
              'No schemas visible.\nToggle system schemas to see more.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted),
            ),
          ),
        ),
      ],
    );
  }
}

class _SchemaNode extends ConsumerStatefulWidget {
  const _SchemaNode({required this.schema, required this.connectionId});

  final DbSchema schema;
  final String connectionId;

  @override
  ConsumerState<_SchemaNode> createState() => _SchemaNodeState();
}

class _SchemaNodeState extends ConsumerState<_SchemaNode> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _NodeRow(
          depth: 0,
          expanded: _expanded,
          hasChildren: true,
          icon: Icons.folder_outlined,
          iconColor: colors.schema,
          label: widget.schema.name,
          trailing: widget.schema.isSystem ? const _SystemBadge() : null,
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded) _tables(),
      ],
    );
  }

  Widget _tables() {
    final tablesAsync = ref.watch(tableListProvider(widget.schema.name));
    return tablesAsync.when(
      loading: () => const _NodeLoading(depth: 1),
      error: (error, _) => _NodeError(error: error, depth: 1),
      data: (tables) {
        if (tables.isEmpty) {
          return const _NodeEmpty(depth: 1, label: 'No tables');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final table in tables)
              _TableNode(table: table, connectionId: widget.connectionId),
          ],
        );
      },
    );
  }
}

class _TableNode extends ConsumerStatefulWidget {
  const _TableNode({required this.table, required this.connectionId});

  final DbTable table;
  final String connectionId;

  @override
  ConsumerState<_TableNode> createState() => _TableNodeState();
}

class _TableNodeState extends ConsumerState<_TableNode> {
  bool _expanded = false;

  IconData get _icon => switch (widget.table.kind) {
    DbObjectKind.view => Icons.visibility_outlined,
    DbObjectKind.materializedView => Icons.dynamic_feed_outlined,
    _ => Icons.table_chart_outlined,
  };

  void _openTable() {
    context.pushNamed(
      AppRoute.tableBrowser.name,
      pathParameters: <String, String>{'id': widget.connectionId},
      extra: TableBrowserArgs(
        schema: widget.table.schema,
        table: widget.table.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _NodeRow(
          depth: 1,
          expanded: _expanded,
          hasChildren: true,
          icon: _icon,
          iconColor: colors.accent,
          label: widget.table.name,
          monospace: true,
          trailing: widget.table.isView ? const _ViewBadge() : null,
          onChevronTap: () => setState(() => _expanded = !_expanded),
          onTap: _openTable,
        ),
        if (_expanded) _columns(),
      ],
    );
  }

  Widget _columns() {
    final columnsAsync = ref.watch(
      columnListProvider(widget.table.schema, widget.table.name),
    );
    return columnsAsync.when(
      loading: () => const _NodeLoading(depth: 2),
      error: (error, _) => _NodeError(error: error, depth: 2),
      data: (columns) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final column in columns) _ColumnTile(column: column),
        ],
      ),
    );
  }
}

class _ColumnTile extends StatelessWidget {
  const _ColumnTile({required this.column});

  final DbColumn column;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg + AppSpacing.xxl,
        right: AppSpacing.lg,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            column.isPrimaryKey ? Icons.key_rounded : Icons.circle_outlined,
            size: 13,
            color: column.isPrimaryKey ? colors.operator : colors.textFaint,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(column.name, style: AppTypography.mono(12.5)),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              column.dataType,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.mono(11, color: colors.textMuted),
            ),
          ),
          if (column.isForeignKey) ...<Widget>[
            const SizedBox(width: AppSpacing.xs),
            Tooltip(
              message:
                  '→ ${column.foreignKey!.referencedSchema}'
                  '.${column.foreignKey!.referencedTable}'
                  '.${column.foreignKey!.referencedColumn}',
              child: Icon(Icons.link_rounded, size: 13, color: colors.value),
            ),
          ],
          if (!column.isNullable) ...<Widget>[
            const SizedBox(width: AppSpacing.xs),
            Text(
              'NOT NULL',
              style: AppTypography.mono(9, color: colors.textFaint),
            ),
          ],
        ],
      ),
    );
  }
}

/// A single expandable/tappable row, indented by [depth].
class _NodeRow extends StatelessWidget {
  const _NodeRow({
    required this.depth,
    required this.expanded,
    required this.hasChildren,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.onChevronTap,
    this.trailing,
    this.monospace = false,
  });

  final int depth;
  final bool expanded;
  final bool hasChildren;
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onChevronTap;
  final Widget? trailing;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;
    final labelStyle = monospace
        ? AppTypography.mono(13)
        : theme.textTheme.titleSmall;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md + depth * AppSpacing.xl,
          right: AppSpacing.md,
          top: AppSpacing.sm,
          bottom: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: onChevronTap ?? onTap,
              child: Icon(
                expanded
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_right_rounded,
                size: 20,
                color: hasChildren ? colors.textMuted : Colors.transparent,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _SystemBadge extends StatelessWidget {
  const _SystemBadge();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    return Text(
      'system',
      style: AppTypography.mono(9, color: colors.textFaint),
    );
  }
}

class _ViewBadge extends StatelessWidget {
  const _ViewBadge();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    return Text('view', style: AppTypography.mono(9, color: colors.value));
  }
}

class _NodeLoading extends StatelessWidget {
  const _NodeLoading({required this.depth});

  final int depth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md + depth * AppSpacing.xl + AppSpacing.lg,
        top: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _NodeEmpty extends StatelessWidget {
  const _NodeEmpty({required this.depth, required this.label});

  final int depth;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md + depth * AppSpacing.xl + AppSpacing.lg,
        top: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        label,
        style: AppTypography.mono(11, color: colors.textFaint),
      ),
    );
  }
}

class _NodeError extends StatelessWidget {
  const _NodeError({required this.error, this.depth = 0, this.padded = false});

  final Object error;
  final int depth;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    final message = error is AppException
        ? (error as AppException).message
        : '$error';
    return Padding(
      padding: padded
          ? const EdgeInsets.all(AppSpacing.xxl)
          : EdgeInsets.only(
              left: AppSpacing.md + depth * AppSpacing.xl + AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.xs,
              bottom: AppSpacing.sm,
            ),
      child: Row(
        children: <Widget>[
          Icon(Icons.error_outline_rounded, size: 14, color: colors.danger),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              message,
              style: TextStyle(color: colors.danger, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
