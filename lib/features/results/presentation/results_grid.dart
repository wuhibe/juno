import 'package:flutter/material.dart';
import 'package:juno/core/theme/app_typography.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/db/adapter/models/column_meta.dart';
import 'package:juno/features/results/domain/cell_formatter.dart';
import 'package:trina_grid/trina_grid.dart';

/// The canonical results grid (trina_grid): horizontal scroll, tap-to-sort on
/// the fetched page, NULL as muted italic, long-press a cell to view it full.
///
/// Rows that arrive via "load more" are appended through the state manager (so
/// scroll position is kept); a brand-new query gets a fresh grid via its Key.
class ResultsGrid extends StatefulWidget {
  /// Creates a grid for [columns]/[rows]. [onViewCell] fires on a cell long-press.
  const ResultsGrid({
    required this.columns,
    required this.rows,
    required this.onViewCell,
    super.key,
  });

  /// Result column metadata.
  final List<ColumnMeta> columns;

  /// Row-major raw values.
  final List<List<Object?>> rows;

  /// Called with the column name and raw value when a cell is long-pressed.
  final void Function(String column, Object? value) onViewCell;

  @override
  State<ResultsGrid> createState() => _ResultsGridState();
}

class _ResultsGridState extends State<ResultsGrid> {
  TrinaGridStateManager? _stateManager;
  late List<TrinaColumn> _columns;
  late List<TrinaRow<dynamic>> _initialRows;
  int _appendedCount = 0;

  @override
  void initState() {
    super.initState();
    _columns = _buildColumns();
    _initialRows = <TrinaRow<dynamic>>[
      for (final row in widget.rows) _buildRow(row),
    ];
    _appendedCount = widget.rows.length;
  }

  @override
  void didUpdateWidget(ResultsGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    final manager = _stateManager;
    if (manager != null && widget.rows.length > _appendedCount) {
      final newRows = <TrinaRow<dynamic>>[
        for (final row in widget.rows.sublist(_appendedCount)) _buildRow(row),
      ];
      manager.appendRows(newRows);
      _appendedCount = widget.rows.length;
    }
  }

  List<TrinaColumn> _buildColumns() => <TrinaColumn>[
    for (var i = 0; i < widget.columns.length; i++)
      TrinaColumn(
        title: widget.columns[i].name,
        field: 'c$i',
        type: TrinaColumnType.text(),
        readOnly: true,
        renderer: (context) => _GridCell(
          value: context.cell.value,
          onLongPress: () =>
              widget.onViewCell(context.column.title, context.cell.value),
        ),
      ),
  ];

  TrinaRow<dynamic> _buildRow(List<Object?> values) => TrinaRow<dynamic>(
    cells: <String, TrinaCell>{
      for (var i = 0; i < widget.columns.length; i++)
        'c$i': TrinaCell(value: i < values.length ? values[i] : null),
    },
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    return TrinaGrid(
      columns: _columns,
      rows: _initialRows,
      onLoaded: (event) => _stateManager = event.stateManager,
      configuration: TrinaGridConfiguration(
        style: TrinaGridStyleConfig.dark(
          gridBackgroundColor: colors.surface,
          rowColor: colors.surface,
          activatedColor: colors.surfaceAlt,
          activatedBorderColor: colors.accent,
          inactivatedBorderColor: colors.border,
          borderColor: colors.border,
          gridBorderColor: colors.border,
          iconColor: colors.textMuted,
          enableGridBorderShadow: false,
          columnTextStyle: AppTypography.mono(
            12,
            weight: FontWeight.w600,
            color: colors.textPrimary,
          ),
          cellTextStyle: AppTypography.mono(12.5, color: colors.textPrimary),
        ),
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({required this.value, required this.onLongPress});

  final Object? value;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    final isNull = value == null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          isNull ? 'NULL' : formatCellValue(value),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.mono(
            12.5,
            color: isNull ? colors.textFaint : colors.textPrimary,
          ).copyWith(fontStyle: isNull ? FontStyle.italic : FontStyle.normal),
        ),
      ),
    );
  }
}
