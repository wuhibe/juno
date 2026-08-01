import 'package:flutter/material.dart';

import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/app_typography.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:juno/db/adapter/models/table_query.dart';

/// Builds one filter condition without typing SQL: pick a column, an operator,
/// and a value. Enum columns offer their labels instead of a free-text field.
class ColumnFilterSheet extends StatefulWidget {
  /// Creates the sheet for the table's [columns].
  const ColumnFilterSheet({required this.columns, super.key});

  /// The table's columns, from the schema cache.
  final List<DbColumn> columns;

  /// Shows the sheet and resolves with the new filter, or null if dismissed.
  static Future<ColumnFilter?> show(
    BuildContext context, {
    required List<DbColumn> columns,
  }) {
    return showModalBottomSheet<ColumnFilter>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ColumnFilterSheet(columns: columns),
    );
  }

  @override
  State<ColumnFilterSheet> createState() => _ColumnFilterSheetState();
}

class _ColumnFilterSheetState extends State<ColumnFilterSheet> {
  late DbColumn _column = widget.columns.first;
  FilterOperator _operator = FilterOperator.eq;
  final TextEditingController _value = TextEditingController();
  final Set<String> _selectedLabels = <String>{};

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  List<String> get _values {
    if (_column.isEnum) {
      return _selectedLabels.toList();
    }
    final text = _value.text.trim();
    if (_operator.takesManyValues) {
      return text
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList();
    }
    return <String>[text];
  }

  bool get _isComplete => ColumnFilter(
    column: _column.name,
    op: _operator,
    values: _values,
  ).isComplete;

  void _selectColumn(DbColumn column) {
    setState(() {
      _column = column;
      _selectedLabels.clear();
      _value.clear();
      // An enum's natural filter is membership; keep the operator usable.
      if (column.isEnum && FilterOperator.textOnly.contains(_operator)) {
        _operator = FilterOperator.eq;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Add filter', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<DbColumn>(
              initialValue: _column,
              decoration: const InputDecoration(labelText: 'Column'),
              items: <DropdownMenuItem<DbColumn>>[
                for (final column in widget.columns)
                  DropdownMenuItem<DbColumn>(
                    value: column,
                    child: Text(
                      '${column.name}  ${column.dataType}',
                      style: AppTypography.mono(13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (column) {
                if (column != null) {
                  _selectColumn(column);
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<FilterOperator>(
              initialValue: _operator,
              decoration: const InputDecoration(labelText: 'Condition'),
              items: <DropdownMenuItem<FilterOperator>>[
                for (final op in _operatorsFor(_column))
                  DropdownMenuItem<FilterOperator>(
                    value: op,
                    child: Text(op.label),
                  ),
              ],
              onChanged: (op) {
                if (op != null) {
                  setState(() => _operator = op);
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            if (!_operator.takesNoValue) _valueField(colors),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _isComplete
                  ? () => Navigator.of(context).pop(
                      ColumnFilter(
                        column: _column.name,
                        op: _operator,
                        values: _values,
                      ),
                    )
                  : null,
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _valueField(JunoColors colors) {
    final enumValues = _column.enumValues;
    if (enumValues != null) {
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: <Widget>[
          for (final label in enumValues)
            FilterChip(
              label: Text(label, style: AppTypography.mono(12)),
              selected: _selectedLabels.contains(label),
              showCheckmark: false,
              selectedColor: colors.schema.withValues(alpha: 0.18),
              side: BorderSide(
                color: _selectedLabels.contains(label)
                    ? colors.schema
                    : colors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              onSelected: (selected) => setState(() {
                // Single-value operators keep exactly one label selected.
                if (!_operator.takesManyValues) {
                  _selectedLabels.clear();
                }
                if (selected) {
                  _selectedLabels.add(label);
                } else {
                  _selectedLabels.remove(label);
                }
              }),
            ),
        ],
      );
    }

    return TextField(
      controller: _value,
      autofocus: true,
      style: AppTypography.mono(14),
      decoration: InputDecoration(
        labelText: _operator.takesManyValues
            ? 'Values (comma separated)'
            : 'Value',
      ),
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) {
        if (_isComplete) {
          Navigator.of(context).pop(
            ColumnFilter(column: _column.name, op: _operator, values: _values),
          );
        }
      },
    );
  }

  /// Text matching is offered on every type — the adapter casts to text — but
  /// booleans only sensibly compare for equality.
  List<FilterOperator> _operatorsFor(DbColumn column) {
    if (column.dataType == 'boolean') {
      return <FilterOperator>[
        FilterOperator.eq,
        FilterOperator.notEq,
        FilterOperator.isNull,
        FilterOperator.isNotNull,
      ];
    }
    return FilterOperator.values;
  }
}
