import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juno/db/adapter/database_adapter.dart';
import 'package:juno/db/adapter/models/column_meta.dart';
import 'package:juno/db/adapter/models/connection_config.dart';
import 'package:juno/db/adapter/models/query_result.dart';
import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:juno/db/adapter/models/table_query.dart';
import 'package:juno/features/connections/application/active_connection_provider.dart';
import 'package:juno/features/editor/application/query_runner_provider.dart';

/// Records executed SQL and returns a configurable number of rows per call.
class _FakeAdapter implements DatabaseAdapter {
  _FakeAdapter(this.rowCounts);

  final List<int> rowCounts;
  final List<String> executed = <String>[];
  int _call = 0;

  @override
  Future<QueryResult> execute(
    String sql, {
    Map<String, Object?>? params,
    Duration? timeout,
  }) async {
    executed.add(sql);
    final count = _call < rowCounts.length ? rowCounts[_call] : 0;
    _call++;
    return QueryResult(
      columns: const <ColumnMeta>[
        ColumnMeta(name: 'n', dbType: 'int4', typeOid: 23),
      ],
      rows: <List<Object?>>[
        for (var i = 0; i < count; i++) <Object?>[i],
      ],
      affectedRows: 0,
      elapsed: const Duration(milliseconds: 1),
    );
  }

  @override
  String limitClause(int limit, int offset) =>
      offset > 0 ? 'LIMIT $limit OFFSET $offset' : 'LIMIT $limit';

  @override
  ({String sql, Map<String, Object?> params}) buildTableQuery({
    required String schema,
    required String table,
    required int limit,
    List<ColumnFilter> filters = const <ColumnFilter>[],
    ColumnSort? sort,
    int offset = 0,
  }) => throw UnimplementedError();

  @override
  String quoteIdentifier(String raw) => '"$raw"';

  @override
  DatabaseKind get kind => DatabaseKind.postgres;
  @override
  bool get isConnected => true;
  @override
  Future<void> connect(ConnectionConfig config) => throw UnimplementedError();
  @override
  Future<void> disconnect() => throw UnimplementedError();
  @override
  Future<Duration> ping() => throw UnimplementedError();
  @override
  Future<void> cancelRunning() => throw UnimplementedError();
  @override
  Future<List<DbSchema>> listSchemas({bool includeSystem = false}) =>
      throw UnimplementedError();
  @override
  Future<List<DbTable>> listTables(String schema) => throw UnimplementedError();
  @override
  Future<List<DbColumn>> listColumns(String schema, String table) =>
      throw UnimplementedError();
}

ProviderContainer _container(_FakeAdapter adapter) {
  final container = ProviderContainer(
    overrides: [activeAdapterProvider.overrideWith((ref) => adapter)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('a bare SELECT is auto-paginated with LIMIT', () async {
    final adapter = _FakeAdapter(<int>[queryPageSize]);
    final container = _container(adapter);

    await container.read(queryRunnerProvider.notifier).run('SELECT * FROM t');

    expect(adapter.executed.single, 'SELECT * FROM t LIMIT $queryPageSize');
    final state = container.read(queryRunnerProvider);
    expect(state, isA<QueryRunSuccess>());
    final success = state as QueryRunSuccess;
    expect(success.paginated, isTrue);
    expect(success.rows, hasLength(queryPageSize));
    expect(success.canLoadMore, isTrue);
  });

  test('loadMore appends the next page with the right OFFSET', () async {
    final adapter = _FakeAdapter(<int>[queryPageSize, 50]);
    final container = _container(adapter);
    final runner = container.read(queryRunnerProvider.notifier);

    await runner.run('SELECT * FROM t');
    await runner.loadMore();

    expect(adapter.executed, <String>[
      'SELECT * FROM t LIMIT $queryPageSize',
      'SELECT * FROM t LIMIT $queryPageSize OFFSET $queryPageSize',
    ]);
    final success = container.read(queryRunnerProvider) as QueryRunSuccess;
    expect(success.rows, hasLength(queryPageSize + 50));
    expect(success.canLoadMore, isFalse);
  });

  test('a non-SELECT runs verbatim, without a LIMIT', () async {
    final adapter = _FakeAdapter(<int>[0]);
    final container = _container(adapter);

    await container
        .read(queryRunnerProvider.notifier)
        .run('CREATE TABLE t (id int)');

    expect(adapter.executed.single, 'CREATE TABLE t (id int)');
    final success = container.read(queryRunnerProvider) as QueryRunSuccess;
    expect(success.paginated, isFalse);
    expect(success.canLoadMore, isFalse);
  });
}
