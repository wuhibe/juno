import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juno/db/adapter/database_adapter.dart';
import 'package:juno/db/adapter/models/connection_config.dart';
import 'package:juno/db/adapter/models/query_result.dart';
import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:juno/db/adapter/models/table_query.dart';
import 'package:juno/features/connections/application/active_connection_provider.dart';
import 'package:juno/features/editor/application/autocomplete_index_provider.dart';

/// Returns one table per schema, named after the schema, so the test can assert
/// which schemas were flattened into the index.
class _FakeAdapter implements DatabaseAdapter {
  @override
  DatabaseKind get kind => DatabaseKind.postgres;
  @override
  bool get isConnected => true;

  @override
  Future<List<DbSchema>> listSchemas({bool includeSystem = false}) async {
    return <DbSchema>[
      const DbSchema(name: 'public', isSystem: false),
      const DbSchema(name: 'analytics', isSystem: false),
      const DbSchema(name: 'pg_catalog', isSystem: true),
    ];
  }

  @override
  Future<List<DbTable>> listTables(String schema) async => <DbTable>[
    DbTable(schema: schema, name: '${schema}_table', kind: DbObjectKind.table),
  ];

  @override
  Future<List<DbColumn>> listColumns(String schema, String table) async =>
      const <DbColumn>[];

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

void main() {
  test('autocompleteTables flattens non-system schemas only', () async {
    final container = ProviderContainer(
      overrides: [activeAdapterProvider.overrideWith((ref) => _FakeAdapter())],
    );
    addTearDown(container.dispose);

    final tables = await container.read(autocompleteTablesProvider.future);
    expect(tables.map((t) => t.name), <String>[
      'public_table',
      'analytics_table',
    ]);
    expect(tables.map((t) => t.schema), isNot(contains('pg_catalog')));
  });
}
