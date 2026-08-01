/// Metadata for one column in a [QueryResult] — the shape the driver reports
/// for a result set.
///
/// This describes a *result* column, which is intentionally narrower than a
/// schema column (`DbColumn`): a result set doesn't reliably carry nullability,
/// primary-key, or foreign-key information, so those live on `DbColumn` only.
class ColumnMeta {
  /// Creates result-column metadata.
  const ColumnMeta({
    required this.name,
    required this.dbType,
    required this.typeOid,
  });

  /// The column's output name (alias or source column).
  final String name;

  /// Readable Postgres type name, e.g. `text`, `int4`, `timestamptz`.
  final String dbType;

  /// The Postgres type OID — used to pick a per-type value formatter.
  final int typeOid;

  @override
  String toString() => 'ColumnMeta($name: $dbType)';
}
