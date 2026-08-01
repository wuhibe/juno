import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juno/db/adapter/database_adapter.dart';
import 'package:juno/db/adapter/models/connection_config.dart';
import 'package:juno/db/adapter/models/query_result.dart';
import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:juno/db/adapter/models/table_query.dart';
import 'package:juno/features/browser/application/schema_cache_provider.dart';
import 'package:juno/features/connections/application/active_connection_provider.dart';

/// A canned adapter: introspection methods return fixtures, everything else
/// is unused by these provider tests.
class _FakeAdapter implements DatabaseAdapter {
  @override
  DatabaseKind get kind => DatabaseKind.postgres;

  @override
  bool get isConnected => true;

  @override
  Future<List<DbSchema>> listSchemas({bool includeSystem = false}) async {
    return <DbSchema>[
      const DbSchema(name: 'public', isSystem: false),
      if (includeSystem) const DbSchema(name: 'pg_catalog', isSystem: true),
    ];
  }

  @override
  Future<List<DbTable>> listTables(String schema) async => <DbTable>[
    DbTable(schema: schema, name: 'users', kind: DbObjectKind.table),
  ];

  @override
  Future<List<DbColumn>> listColumns(String schema, String table) async =>
      const <DbColumn>[
        DbColumn(
          name: 'id',
          dataType: 'int4',
          isNullable: false,
          isPrimaryKey: true,
          ordinalPosition: 1,
        ),
      ];

  @override
  Future<void> connect(ConnectionConfig config) => throw UnimplementedError();
  @override
  Future<void> disconnect() => throw UnimplementedError();
  @override
  Future<Duration> ping() => throw UnimplementedError();
  @override
  Future<QueryResult> execute(
    String sql, {
    Map<String, Object?>? params,
    Duration? timeout,
  }) => throw UnimplementedError();
  @override
  Future<void> cancelRunning() => throw UnimplementedError();
  @override
  String quoteIdentifier(String raw) => '"$raw"';
  @override
  String limitClause(int limit, int offset) => 'LIMIT $limit';
  @override
  ({String sql, Map<String, Object?> params}) buildTableQuery({
    required String schema,
    required String table,
    required int limit,
    List<ColumnFilter> filters = const <ColumnFilter>[],
    ColumnSort? sort,
    int offset = 0,
  }) => throw UnimplementedError();
}

ProviderContainer _container() {
  final container = ProviderContainer(
    overrides: [activeAdapterProvider.overrideWith((ref) => _FakeAdapter())],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('schemaList hides system schemas by default', () async {
    final container = _container();
    final schemas = await container.read(schemaListProvider.future);
    expect(schemas.map((s) => s.name), <String>['public']);
  });

  test('toggling ShowSystemSchemas re-includes system schemas', () async {
    final container = _container();

    expect(await container.read(schemaListProvider.future), hasLength(1));

    container.read(showSystemSchemasProvider.notifier).toggle();
    final withSystem = await container.read(schemaListProvider.future);
    expect(withSystem.map((s) => s.name), contains('pg_catalog'));
  });

  test('tableList and columnList delegate to the adapter', () async {
    final container = _container();

    final tables = await container.read(tableListProvider('public').future);
    expect(tables.single.name, 'users');

    final columns = await container.read(
      columnListProvider('public', 'users').future,
    );
    expect(columns.single.isPrimaryKey, isTrue);
  });
}
