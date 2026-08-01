/// How a [ColumnFilter] compares its column against its values.
enum FilterOperator {
  /// `column = value`.
  eq('=', 'equals'),

  /// `column <> value`.
  notEq('≠', 'not equals'),

  /// `column > value`.
  gt('>', 'greater than'),

  /// `column >= value`.
  gte('≥', 'at least'),

  /// `column < value`.
  lt('<', 'less than'),

  /// `column <= value`.
  lte('≤', 'at most'),

  /// Case-insensitive substring match.
  contains('contains', 'contains'),

  /// Case-insensitive prefix match.
  startsWith('starts with', 'starts with'),

  /// Membership in a set of values.
  inList('in', 'is one of'),

  /// `column IS NULL`.
  isNull('is null', 'is null'),

  /// `column IS NOT NULL`.
  isNotNull('is not null', 'is not null');

  const FilterOperator(this.symbol, this.label);

  /// Short glyph for chips (`=`, `≥`, `contains`).
  final String symbol;

  /// Human label for the operator picker.
  final String label;

  /// Whether this operator compares against no value at all.
  bool get takesNoValue =>
      this == FilterOperator.isNull || this == FilterOperator.isNotNull;

  /// Whether this operator compares against a list of values.
  bool get takesManyValues => this == FilterOperator.inList;

  /// Operators that only make sense for text-shaped comparisons.
  static const Set<FilterOperator> textOnly = <FilterOperator>{
    FilterOperator.contains,
    FilterOperator.startsWith,
  };
}

/// One condition in a table filter, in driver-agnostic terms.
///
/// [values] are always the user's raw text; the adapter binds them as untyped
/// parameters so the server coerces them to the column's real type (which is
/// what makes filtering enum, numeric, and timestamp columns work without the
/// app knowing anything about types).
class ColumnFilter {
  /// Creates a filter condition.
  const ColumnFilter({
    required this.column,
    required this.op,
    this.values = const <String>[],
  });

  /// The column to filter on.
  final String column;

  /// How to compare.
  final FilterOperator op;

  /// The comparison values: empty for [FilterOperator.isNull]/[isNotNull], one
  /// for most operators, one or more for [FilterOperator.inList].
  final List<String> values;

  /// Whether this filter carries the values its operator needs.
  bool get isComplete =>
      op.takesNoValue || values.any((value) => value.isNotEmpty);

  /// A short human rendering for a filter chip, e.g. `status = active`.
  String get label => op.takesNoValue
      ? '$column ${op.symbol}'
      : '$column ${op.symbol} ${values.join(', ')}';

  @override
  String toString() => 'ColumnFilter($label)';
}

/// Sort direction for a [ColumnSort].
enum SortDirection {
  /// Ascending.
  asc,

  /// Descending.
  desc,
}

/// A single-column ORDER BY.
class ColumnSort {
  /// Creates a sort spec.
  const ColumnSort({required this.column, required this.direction});

  /// The column to order by.
  final String column;

  /// The direction to order in.
  final SortDirection direction;

  @override
  String toString() => 'ColumnSort($column ${direction.name})';
}
