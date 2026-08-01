import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juno/db/adapter/database_adapter.dart';
import 'package:juno/db/adapter/models/column_meta.dart';
import 'package:juno/db/adapter/models/connection_config.dart';
import 'package:juno/db/adapter/models/query_result.dart';
import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:juno/db/adapter/models/table_query.dart';
import 'package:juno/features/browser/application/table_browse_provider.dart';
import 'package:juno/features/connections/application/active_connection_provider.dart';

/// Records the specs it was asked to build and returns a configurable number of
/// rows per execute call.
class _FakeAdapter implements DatabaseAdapter {
  _FakeAdapter(this.rowCounts);

  final List<int> rowCounts;
  final List<({List<ColumnFilter> filters, ColumnSort? sort, int offset})>
  builds = <({List<ColumnFilter> filters, ColumnSort? sort, int offset})>[];
  int _call = 0;

  @override
  ({String sql, Map<String, Object?> params}) buildTableQuery({
    required String schema,
    required String table,
    required int limit,
    List<ColumnFilter> filters = const <ColumnFilter>[],
    ColumnSort? sort,
    int offset = 0,
  }) {
    builds.add((filters: filters, sort: sort, offset: offset));
    return (sql: 'SELECT * FROM $schema.$table', params: <String, Object?>{});
  }

  @override
  Future<QueryResult> execute(
    String sql, {
    Map<String, Object?>? params,
    Duration? timeout,
  }) async {
    final count = _call < rowCounts.length ? rowCounts[_call] : 0;
    _call++;
    return QueryResult(
      columns: const <ColumnMeta>[
        ColumnMeta(name: 'id', dbType: 'int4', typeOid: 23),
      ],
      rows: <List<Object?>>[
        for (var i = 0; i < count; i++) <Object?>[i],
      ],
      affectedRows: 0,
      elapsed: const Duration(milliseconds: 1),
    );
  }

  @override
  String quoteIdentifier(String raw) => '"$raw"';
  @override
  String limitClause(int limit, int offset) => 'LIMIT $limit';
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
  // The provider auto-disposes without a listener, exactly as it does when the
  // browse screen is popped.
  container.listen(
    tableBrowseProvider('public', 'users'),
    (_, _) {},
    fireImmediately: true,
  );
  return container;
}

const ColumnFilter _activeOnly = ColumnFilter(
  column: 'status',
  op: FilterOperator.eq,
  values: <String>['active'],
);

void main() {
  final provider = tableBrowseProvider('public', 'users');

  test('loads the first page on creation', () async {
    final adapter = _FakeAdapter(<int>[tableBrowsePageSize]);
    final container = _container(adapter);

    container.read(provider.notifier);
    await pumpEventQueue();

    expect(adapter.builds.single.offset, 0);
    final state = container.read(provider);
    expect(state.loading, isFalse);
    expect(state.rows, hasLength(tableBrowsePageSize));
    expect(state.canLoadMore, isTrue);
  });

  test('loadMore appends the next page at the right offset', () async {
    final adapter = _FakeAdapter(<int>[tableBrowsePageSize, 20]);
    final container = _container(adapter);
    final browse = container.read(provider.notifier);
    await pumpEventQueue();

    await browse.loadMore();

    expect(adapter.builds.last.offset, tableBrowsePageSize);
    final state = container.read(provider);
    expect(state.rows, hasLength(tableBrowsePageSize + 20));
    expect(state.canLoadMore, isFalse);
  });

  test('a short first page offers no "load more"', () async {
    final adapter = _FakeAdapter(<int>[3]);
    final container = _container(adapter);
    container.read(provider.notifier);
    await pumpEventQueue();

    expect(container.read(provider).canLoadMore, isFalse);
  });

  test('applying a filter re-queries from the first page', () async {
    final adapter = _FakeAdapter(<int>[tableBrowsePageSize, 5]);
    final container = _container(adapter);
    final browse = container.read(provider.notifier);
    await pumpEventQueue();

    browse.applyFilters(<ColumnFilter>[_activeOnly]);
    await pumpEventQueue();

    expect(adapter.builds.last.filters, <ColumnFilter>[_activeOnly]);
    expect(adapter.builds.last.offset, 0);
    final state = container.read(provider);
    expect(state.rows, hasLength(5));
    expect(state.filters, hasLength(1));
  });

  test('sorting re-queries and clearing it drops the ORDER BY', () async {
    final adapter = _FakeAdapter(<int>[1, 1, 1]);
    final container = _container(adapter);
    final browse = container.read(provider.notifier);
    await pumpEventQueue();

    browse.sortBy('id', SortDirection.desc);
    await pumpEventQueue();
    expect(adapter.builds.last.sort?.direction, SortDirection.desc);

    browse.sortBy('id', null);
    await pumpEventQueue();
    expect(adapter.builds.last.sort, isNull);
  });

  test('removing a filter re-queries without it', () async {
    final adapter = _FakeAdapter(<int>[1, 1, 1]);
    final container = _container(adapter);
    final browse = container.read(provider.notifier);
    await pumpEventQueue();

    browse.applyFilters(<ColumnFilter>[_activeOnly]);
    await pumpEventQueue();
    browse.removeFilterAt(0);
    await pumpEventQueue();

    expect(adapter.builds.last.filters, isEmpty);
    expect(container.read(provider).filters, isEmpty);
  });
}
