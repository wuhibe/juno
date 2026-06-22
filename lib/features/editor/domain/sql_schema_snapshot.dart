import 'package:juno/db/adapter/models/schema_objects.dart';

/// A synchronous, point-in-time view of the schema cache for the autocomplete
/// engine to read.
///
/// The engine is a pure function of `(text, snapshot)`; all async loading lives
/// in the provider/widget layer, which assembles this from the keep-alive
/// schema caches before each suggestion pass.
class SqlSchemaSnapshot {
  /// Creates a snapshot from already-loaded [tables] and [columnsByTable].
  const SqlSchemaSnapshot({required this.tables, required this.columnsByTable});

  /// An empty snapshot — used while the schema cache is still loading.
  static const SqlSchemaSnapshot empty = SqlSchemaSnapshot(
    tables: <DbTable>[],
    columnsByTable: <String, List<DbColumn>>{},
  );

  /// All known tables/views across the visible (non-system) schemas.
  final List<DbTable> tables;

  /// Columns keyed by lower-cased bare table name, for whatever tables have
  /// been resolved so far (loaded lazily as a query references them).
  final Map<String, List<DbColumn>> columnsByTable;

  /// The columns known for [tableName] (case-insensitive), or empty if not yet
  /// loaded.
  List<DbColumn> columnsFor(String tableName) =>
      columnsByTable[tableName.toLowerCase()] ?? const <DbColumn>[];
}
