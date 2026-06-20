import 'package:juno/db/adapter/models/column_meta.dart';

/// The driver-agnostic outcome of executing a SQL statement.
///
/// UI and state layers consume only this — never a driver-specific result type.
class QueryResult {
  /// Creates a query result.
  const QueryResult({
    required this.columns,
    required this.rows,
    required this.affectedRows,
    required this.elapsed,
  });

  /// Column metadata, in result order. Empty for statements with no result set.
  final List<ColumnMeta> columns;

  /// Row-major cell values; each inner list aligns with [columns]. A SQL `NULL`
  /// is represented as Dart `null`.
  final List<List<Object?>> rows;

  /// Rows affected by a DML statement (INSERT/UPDATE/DELETE); 0 for SELECTs.
  final int affectedRows;

  /// Server round-trip time for the statement.
  final Duration elapsed;

  /// Whether the result carries any rows.
  bool get hasRows => rows.isNotEmpty;

  /// Number of rows returned.
  int get rowCount => rows.length;

  @override
  String toString() =>
      'QueryResult(columns: ${columns.length}, rows: $rowCount, '
      'affected: $affectedRows, elapsed: ${elapsed.inMilliseconds}ms)';
}
