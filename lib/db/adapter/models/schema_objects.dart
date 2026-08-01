/// The kind of relation a [DbTable] represents.
enum DbObjectKind {
  /// An ordinary table.
  table,

  /// A view.
  view,

  /// A materialized view.
  materializedView,

  /// A partitioned (parent) table.
  partitionedTable,
}

/// A database schema (namespace).
class DbSchema {
  /// Creates a schema descriptor.
  const DbSchema({required this.name, required this.isSystem});

  /// The schema name (e.g. `public`).
  final String name;

  /// Whether this is an engine-internal schema (`pg_catalog`,
  /// `information_schema`, `pg_*`) normally hidden behind a "show system" toggle.
  final bool isSystem;

  @override
  String toString() => 'DbSchema($name${isSystem ? ', system' : ''})';
}

/// A table, view, or materialized view within a schema.
class DbTable {
  /// Creates a table/view descriptor.
  const DbTable({required this.schema, required this.name, required this.kind});

  /// The owning schema name.
  final String schema;

  /// The relation name.
  final String name;

  /// What kind of relation this is.
  final DbObjectKind kind;

  /// Whether this relation is a (materialized) view rather than a base table.
  bool get isView =>
      kind == DbObjectKind.view || kind == DbObjectKind.materializedView;

  @override
  String toString() => 'DbTable($schema.$name, $kind)';
}

/// A foreign-key relationship from a column to a referenced column.
class DbForeignKey {
  /// Creates a foreign-key descriptor.
  const DbForeignKey({
    required this.constraintName,
    required this.referencedSchema,
    required this.referencedTable,
    required this.referencedColumn,
  });

  /// The constraint name (`pg_constraint.conname`).
  final String constraintName;

  /// Schema of the referenced table.
  final String referencedSchema;

  /// The referenced table.
  final String referencedTable;

  /// The referenced column.
  final String referencedColumn;

  @override
  String toString() =>
      'DbForeignKey(-> $referencedSchema.$referencedTable.$referencedColumn)';
}

/// A column within a [DbTable], as reported by introspection.
class DbColumn {
  /// Creates a schema-column descriptor.
  const DbColumn({
    required this.name,
    required this.dataType,
    required this.isNullable,
    required this.isPrimaryKey,
    required this.ordinalPosition,
    this.foreignKey,
    this.enumValues,
  });

  /// The column name.
  final String name;

  /// The readable, fully-qualified type (e.g. `character varying(255)`).
  final String dataType;

  /// Whether the column accepts NULL.
  final bool isNullable;

  /// Whether the column participates in the table's primary key.
  final bool isPrimaryKey;

  /// 1-based position of the column within the table.
  final int ordinalPosition;

  /// The foreign key this column participates in, if any.
  final DbForeignKey? foreignKey;

  /// The allowed labels when this column's type is an enum, in declaration
  /// order; null for every other type. Drives the filter value picker.
  final List<String>? enumValues;

  /// Whether this column references another table.
  bool get isForeignKey => foreignKey != null;

  /// Whether this column's type is an enum.
  bool get isEnum => enumValues != null;

  @override
  String toString() =>
      'DbColumn($name $dataType${isPrimaryKey ? ' PK' : ''}'
      '${isNullable ? '' : ' NOT NULL'})';
}
