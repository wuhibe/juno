import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:postgres/postgres.dart' as pg;

/// Holds the `pg_catalog` introspection queries that drive the schema browser
/// and (later) autocomplete. Kept separate from the adapter so all app-generated
/// SQL for Postgres lives in one auditable place.
class PostgresIntrospection {
  /// Creates an introspector.
  const PostgresIntrospection();

  static const Set<String> _systemSchemas = <String>{
    'pg_catalog',
    'information_schema',
  };

  /// Lists schemas (namespaces). Temp/toast schemas are always hidden; other
  /// engine-internal schemas are flagged via [DbSchema.isSystem].
  Future<List<DbSchema>> listSchemas(
    pg.Session session, {
    bool includeSystem = false,
  }) async {
    final result = await session.execute(
      'SELECT nspname FROM pg_catalog.pg_namespace '
      "WHERE nspname NOT LIKE 'pg_temp_%' "
      "AND nspname NOT LIKE 'pg_toast_temp_%' "
      'ORDER BY nspname',
    );

    final schemas = <DbSchema>[];
    for (final row in result) {
      final name = row[0]! as String;
      final isSystem = _systemSchemas.contains(name) || name.startsWith('pg_');
      if (isSystem && !includeSystem) {
        continue;
      }
      schemas.add(DbSchema(name: name, isSystem: isSystem));
    }
    return schemas;
  }

  /// Lists tables, views, materialized views, and partitioned tables in [schema].
  Future<List<DbTable>> listTables(pg.Session session, String schema) async {
    final result = await session.execute(
      pg.Sql.named(
        'SELECT c.relname, c.relkind::text '
        'FROM pg_catalog.pg_class c '
        'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace '
        // relkind is the internal "char" type; cast to text so the comparison
        // resolves under the driver's prepared (extended) protocol.
        "WHERE n.nspname = @schema AND c.relkind::text = ANY(ARRAY['r','v','m','p']) "
        'ORDER BY c.relname',
      ),
      parameters: <String, Object?>{'schema': schema},
    );

    return <DbTable>[
      for (final row in result)
        DbTable(
          schema: schema,
          name: row[0]! as String,
          kind: _mapRelKind(row[1]! as String),
        ),
    ];
  }

  /// Lists the columns of [schema].[table] with nullability, PK, and FK details.
  Future<List<DbColumn>> listColumns(
    pg.Session session,
    String schema,
    String table,
  ) async {
    final result = await session.execute(
      pg.Sql.named(_columnsSql),
      parameters: <String, Object?>{'schema': schema, 'table': table},
    );

    return <DbColumn>[
      for (final row in result)
        DbColumn(
          ordinalPosition: row[0]! as int,
          name: row[1]! as String,
          dataType: row[2]! as String,
          isNullable: row[3]! as bool,
          isPrimaryKey: row[4]! as bool,
          foreignKey: _foreignKeyFromRow(row),
        ),
    ];
  }

  DbForeignKey? _foreignKeyFromRow(List<Object?> row) {
    final constraintName = row[5] as String?;
    if (constraintName == null) {
      return null;
    }
    return DbForeignKey(
      constraintName: constraintName,
      referencedSchema: row[6]! as String,
      referencedTable: row[7]! as String,
      referencedColumn: row[8]! as String,
    );
  }

  DbObjectKind _mapRelKind(String relkind) => switch (relkind) {
    'v' => DbObjectKind.view,
    'm' => DbObjectKind.materializedView,
    'p' => DbObjectKind.partitionedTable,
    _ => DbObjectKind.table,
  };

  /// Column introspection. Resolves the table OID once via the `rel` CTE, then
  /// joins primary-key membership (`contype = 'p'`) and foreign-key targets
  /// (`contype = 'f'`) per column. Column order in the SELECT is depended on by
  /// [listColumns]:
  /// 0 ordinal, 1 name, 2 data_type, 3 is_nullable, 4 is_primary_key,
  /// 5 fk_name, 6 fk_ref_schema, 7 fk_ref_table, 8 fk_ref_column.
  static const String _columnsSql = '''
WITH rel AS (
  SELECT c.oid
  FROM pg_catalog.pg_class c
  JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = @schema AND c.relname = @table
),
cols AS (
  SELECT a.attnum,
         a.attname,
         pg_catalog.format_type(a.atttypid, a.atttypmod) AS data_type,
         NOT a.attnotnull AS is_nullable
  FROM pg_catalog.pg_attribute a
  WHERE a.attrelid = (SELECT oid FROM rel)
    AND a.attnum > 0
    AND NOT a.attisdropped
),
pk AS (
  SELECT pg_catalog.unnest(conkey) AS attnum
  FROM pg_catalog.pg_constraint
  WHERE conrelid = (SELECT oid FROM rel) AND contype = 'p'
),
fk AS (
  SELECT con.conname,
         con.conkey[i] AS attnum,
         fn.nspname AS ref_schema,
         fc.relname AS ref_table,
         fa.attname AS ref_column
  FROM pg_catalog.pg_constraint con
  CROSS JOIN pg_catalog.generate_subscripts(con.conkey, 1) AS i
  JOIN pg_catalog.pg_class fc ON fc.oid = con.confrelid
  JOIN pg_catalog.pg_namespace fn ON fn.oid = fc.relnamespace
  JOIN pg_catalog.pg_attribute fa
    ON fa.attrelid = con.confrelid AND fa.attnum = con.confkey[i]
  WHERE con.conrelid = (SELECT oid FROM rel) AND con.contype = 'f'
)
SELECT c.attnum AS ordinal,
       c.attname AS name,
       c.data_type AS data_type,
       c.is_nullable AS is_nullable,
       (pk.attnum IS NOT NULL) AS is_primary_key,
       fk.conname AS fk_name,
       fk.ref_schema AS fk_ref_schema,
       fk.ref_table AS fk_ref_table,
       fk.ref_column AS fk_ref_column
FROM cols c
LEFT JOIN pk ON pk.attnum = c.attnum
LEFT JOIN fk ON fk.attnum = c.attnum
ORDER BY c.attnum
''';
}
