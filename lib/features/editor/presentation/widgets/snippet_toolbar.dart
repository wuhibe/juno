import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/data/data_providers.dart';
import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:juno/features/browser/application/schema_cache_provider.dart';
import 'package:juno/features/editor/application/active_editor_table_provider.dart';
import 'package:juno/features/editor/application/autocomplete_index_provider.dart';
import 'package:juno/features/editor/domain/snippet_catalog.dart';
import 'package:juno/features/editor/domain/snippet_chip.dart';
import 'package:juno/features/editor/domain/snippet_context.dart';
import 'package:juno/features/editor/domain/snippet_insertion.dart';
import 'package:juno/features/editor/presentation/widgets/snippet_chip_view.dart';
import 'package:juno/features/editor/presentation/widgets/snippet_pick_sheet.dart';
import 'package:re_editor/re_editor.dart';

/// The composable snippet toolbar (plan §8): a horizontally scrollable row of
/// colour-coded chips pinned above the keyboard. Chips insert SQL at the cursor
/// with smart spacing; the chip groups reorder by the cursor's context; smart
/// chips pull tables/columns from the schema cache.
class SnippetToolbar extends ConsumerStatefulWidget {
  /// Creates the toolbar bound to [controller]; keeps focus on [focusNode] after
  /// each insert. [isReadOnly] hides write chips.
  const SnippetToolbar({
    required this.controller,
    required this.focusNode,
    required this.isReadOnly,
    super.key,
  });

  /// The editor's text controller.
  final CodeLineEditingController controller;

  /// The editor's focus node (re-requested after inserts so the keyboard stays).
  final FocusNode focusNode;

  /// Whether the active connection is read-only.
  final bool isReadOnly;

  @override
  ConsumerState<SnippetToolbar> createState() => _SnippetToolbarState();
}

class _SnippetToolbarState extends ConsumerState<SnippetToolbar> {
  static const int _maxTableChips = 12;

  CodeLineEditingController get _controller => widget.controller;

  /// The line index the cursor terminates on, clamped to a valid range (the
  /// selection can be stale right after a modal sheet closes).
  int get _lineIndex => _controller.selection.extentIndex.clamp(
    0,
    _controller.codeLines.length - 1,
  );

  String _textBeforeCursor() {
    final line = _controller.codeLines[_lineIndex].text;
    final offset = _controller.selection.extentOffset.clamp(0, line.length);
    return line.substring(0, offset);
  }

  /// Splices [chip] in at the cursor with smart spacing, then restores focus.
  void _apply(SnippetChip chip) {
    if (!_controller.selection.isCollapsed) {
      _controller.cancelSelection();
    }
    final index = _lineIndex;
    final line = _controller.codeLines[index].text;
    final offset = _controller.selection.extentOffset.clamp(0, line.length);
    final plan = SnippetInserter.plan(
      before: line.substring(0, offset),
      after: line.substring(offset),
      chip: chip,
    );
    _controller.replaceSelection(plan.text);
    _controller.selection = CodeLineSelection.collapsed(
      index: index,
      offset: offset + plan.cursorOffset,
    );
    HapticFeedback.selectionClick();
    widget.focusNode.requestFocus();
  }

  void _insertTable(DbTable table) {
    _apply(
      SnippetChip(
        label: table.name,
        insertText: table.name,
        category: SnippetCategory.smart,
      ),
    );
    ref.read(activeEditorTableProvider.notifier).select(table);
  }

  Future<void> _onFromTap(List<DbTable> tables) async {
    _apply(
      const SnippetChip(
        label: 'FROM',
        insertText: 'FROM',
        category: SnippetCategory.structure,
      ),
    );
    if (tables.isEmpty) {
      return;
    }
    final picked = await SnippetPickSheet.show<DbTable>(
      context,
      title: 'Tables',
      items: tables
          .map(
            (table) => SnippetPickItem<DbTable>(
              value: table,
              label: table.name,
              detail: table.schema,
            ),
          )
          .toList(),
    );
    if (!mounted) {
      return;
    }
    // Insert first (works regardless of focus), then restore focus so the
    // keyboard and toolbar come back.
    if (picked != null) {
      _insertTable(picked);
    }
    widget.focusNode.requestFocus();
  }

  /// Long-press menu: pin/unpin the chip (plan §8 favorites) plus any insert
  /// variants (`JOIN` → LEFT/RIGHT/…, `LIMIT` → 10/100/1000).
  Future<void> _showChipMenu(
    SnippetChip chip,
    Color color,
    Color pressed,
    bool pinned,
  ) async {
    final theme = Theme.of(context);
    final result = await showModalBottomSheet<_ChipMenuResult>(
      context: context,
      backgroundColor: theme.juno.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(
                pinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: theme.juno.schema,
              ),
              title: Text(pinned ? 'Unpin from favorites' : 'Pin to favorites'),
              onTap: () => Navigator.of(context).pop(_TogglePin(pin: !pinned)),
            ),
            if (chip.hasVariants)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    for (final variant in chip.variants)
                      SnippetChipView(
                        label: variant.label,
                        color: color,
                        pressedTextColor: pressed,
                        onTap: () =>
                            Navigator.of(context).pop(_InsertVariant(variant)),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
    switch (result) {
      case _TogglePin(:final pin):
        final repo = ref.read(snippetFavoritesRepositoryProvider);
        await (pin ? repo.pin(chip.label) : repo.unpin(chip.label));
      case _InsertVariant(:final chip):
        _apply(chip);
      case null:
        break;
    }
    // The sheet stole focus; restore it so the toolbar stays visible.
    if (mounted) {
      widget.focusNode.requestFocus();
    }
  }

  Color _categoryColor(SnippetCategory category, JunoColors colors) {
    return switch (category) {
      SnippetCategory.structure => colors.keyword,
      SnippetCategory.operators => colors.operator,
      SnippetCategory.value => colors.value,
      SnippetCategory.smart => colors.schema,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    final tables =
        ref.watch(autocompleteTablesProvider).value ?? const <DbTable>[];
    final activeTable = ref.watch(activeEditorTableProvider);
    final columns = activeTable == null
        ? const <DbColumn>[]
        : ref
                  .watch(
                    columnListProvider(activeTable.schema, activeTable.name),
                  )
                  .value ??
              const <DbColumn>[];
    final favorites =
        ref.watch(snippetFavoritesProvider).value ?? const <String>[];
    final favoriteLabels = favorites.toSet();

    // Mark the toolbar as part of the editor's tap region so tapping a chip
    // does not trigger the editor's onTapOutside → unfocus (which would dismiss
    // the keyboard and hide this bar).
    return CodeEditorTapRegion(
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 48,
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                final context0 = SnippetContext.analyze(_textBeforeCursor());
                final groups = SnippetContext.orderGroups(context0);
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  children: _buildGroups(
                    groups,
                    colors,
                    tables,
                    columns,
                    activeTable,
                    favorites,
                    favoriteLabels,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroups(
    List<SnippetGroup> groups,
    JunoColors colors,
    List<DbTable> tables,
    List<DbColumn> columns,
    DbTable? activeTable,
    List<String> favorites,
    Set<String> favoriteLabels,
  ) {
    final widgets = <Widget>[];

    void addChips(List<Widget> chips) {
      if (chips.isEmpty) {
        return;
      }
      if (widgets.isNotEmpty) {
        widgets.add(_divider(colors));
      }
      for (var i = 0; i < chips.length; i++) {
        if (i > 0) {
          widgets.add(const SizedBox(width: AppSpacing.sm));
        }
        widgets.add(Center(child: chips[i]));
      }
    }

    addChips(_favoriteChips(favorites, colors));
    for (final group in groups) {
      addChips(
        _groupChips(
          group,
          colors,
          tables,
          columns,
          activeTable,
          favoriteLabels,
        ),
      );
    }
    return widgets;
  }

  /// The leading favorites group: pinned catalog chips, in pin order.
  List<Widget> _favoriteChips(List<String> favorites, JunoColors colors) {
    final chips = <Widget>[];
    for (final label in favorites) {
      final chip = SnippetCatalog.byLabel(label);
      if (chip == null || (chip.isWrite && widget.isReadOnly)) {
        continue;
      }
      chips.add(_catalogChip(chip, colors, pinned: true));
    }
    return chips;
  }

  List<Widget> _groupChips(
    SnippetGroup group,
    JunoColors colors,
    List<DbTable> tables,
    List<DbColumn> columns,
    DbTable? activeTable,
    Set<String> favoriteLabels,
  ) {
    switch (group) {
      case SnippetGroup.tables:
        return tables
            .take(_maxTableChips)
            .map(
              (table) => _smartChip(
                table.name,
                colors.schema,
                () => _insertTable(table),
              ),
            )
            .toList();
      case SnippetGroup.columns:
        return columns
            .map(
              (column) => _smartChip(
                column.name,
                colors.schema,
                () => _apply(_bareChip(column.name)),
                onLongPress: activeTable == null
                    ? null
                    : () => _apply(
                        _bareChip('${activeTable.name}.${column.name}'),
                      ),
              ),
            )
            .toList();
      case SnippetGroup.structure:
        return _catalogChips(SnippetCatalog.structure, colors, favoriteLabels);
      case SnippetGroup.operators:
        return _catalogChips(SnippetCatalog.operators, colors, favoriteLabels);
      case SnippetGroup.value:
        return _catalogChips(SnippetCatalog.values, colors, favoriteLabels);
    }
  }

  List<Widget> _catalogChips(
    List<SnippetChip> chips,
    JunoColors colors,
    Set<String> favoriteLabels,
  ) {
    return <Widget>[
      for (final chip in chips)
        if (!(chip.isWrite && widget.isReadOnly))
          _catalogChip(
            chip,
            colors,
            pinned: favoriteLabels.contains(chip.label),
          ),
    ];
  }

  Widget _catalogChip(
    SnippetChip chip,
    JunoColors colors, {
    required bool pinned,
  }) {
    final color = _categoryColor(chip.category, colors);
    final pressed = colors.canvas;
    return SnippetChipView(
      label: chip.label,
      color: color,
      pressedTextColor: pressed,
      hasMenu: chip.hasVariants,
      onTap: () => chip.label == 'FROM'
          ? _onFromTap(
              ref.read(autocompleteTablesProvider).value ?? const <DbTable>[],
            )
          : _apply(chip),
      onLongPress: () => _showChipMenu(chip, color, pressed, pinned),
    );
  }

  Widget _smartChip(
    String label,
    Color color,
    VoidCallback onTap, {
    VoidCallback? onLongPress,
  }) {
    return SnippetChipView(
      label: label,
      color: color,
      pressedTextColor: Theme.of(context).juno.canvas,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  SnippetChip _bareChip(String text) => SnippetChip(
    label: text,
    insertText: text,
    category: SnippetCategory.smart,
  );

  Widget _divider(JunoColors colors) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      color: colors.border,
    );
  }
}

/// Outcome of the long-press chip menu.
sealed class _ChipMenuResult {}

/// Pin or unpin the chip.
class _TogglePin extends _ChipMenuResult {
  _TogglePin({required this.pin});

  final bool pin;
}

/// Insert a chosen variant.
class _InsertVariant extends _ChipMenuResult {
  _InsertVariant(this.chip);

  final SnippetChip chip;
}
