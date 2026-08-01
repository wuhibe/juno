import 'package:juno/core/errors/app_exception.dart';
import 'package:juno/db/adapter/models/column_meta.dart';
import 'package:juno/db/adapter/models/table_query.dart';
import 'package:juno/features/connections/application/active_connection_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'table_browse_provider.g.dart';

/// Rows fetched per page while browsing a table. The LIMIT does the work —
/// browsing a million-row table stays cheap.
const int tableBrowsePageSize = 200;

/// One table's browse session: the filters and sort the user has applied, plus
/// the rows fetched so far.
class TableBrowseState {
  /// Creates a browse state.
  const TableBrowseState({
    this.filters = const <ColumnFilter>[],
    this.sort,
    this.columns = const <ColumnMeta>[],
    this.rows = const <List<Object?>>[],
    this.elapsed = Duration.zero,
    this.queryId = 0,
    this.loading = true,
    this.loadingMore = false,
    this.canLoadMore = false,
    this.nextOffset = 0,
    this.error,
  });

  /// Active filter conditions, AND-joined by the adapter.
  final List<ColumnFilter> filters;

  /// The active ORDER BY, if any.
  final ColumnSort? sort;

  /// Result column metadata.
  final List<ColumnMeta> columns;

  /// Accumulated rows across all loaded pages.
  final List<List<Object?>> rows;

  /// Server round-trip time of the first page.
  final Duration elapsed;

  /// Bumped on every fresh load (not on "load more"), so the grid can tell a
  /// new result from an appended page.
  final int queryId;

  /// Whether the first page is in flight.
  final bool loading;

  /// Whether a "load more" fetch is in flight.
  final bool loadingMore;

  /// Whether another page is likely available.
  final bool canLoadMore;

  /// Offset for the next page.
  final int nextOffset;

  /// The typed, user-safe error of the last failed load.
  final AppException? error;

  /// Copies with the given fields replaced. Pass [clearError] to drop an error.
  TableBrowseState copyWith({
    List<ColumnFilter>? filters,
    ColumnSort? sort,
    bool clearSort = false,
    List<ColumnMeta>? columns,
    List<List<Object?>>? rows,
    Duration? elapsed,
    int? queryId,
    bool? loading,
    bool? loadingMore,
    bool? canLoadMore,
    int? nextOffset,
    AppException? error,
    bool clearError = false,
  }) {
    return TableBrowseState(
      filters: filters ?? this.filters,
      sort: clearSort ? null : (sort ?? this.sort),
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      elapsed: elapsed ?? this.elapsed,
      queryId: queryId ?? this.queryId,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      nextOffset: nextOffset ?? this.nextOffset,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Browses `schema.table` with server-side filtering, sorting, and paging.
///
/// Every statement is built by the adapter from [ColumnFilter]/[ColumnSort]
/// specs, so no SQL is assembled here and filter values travel as bound
/// parameters.
@riverpod
class TableBrowse extends _$TableBrowse {
  int _queryCounter = 0;

  @override
  TableBrowseState build(String schema, String table) {
    Future<void>.microtask(() {
      // The screen can be popped before the first page lands.
      if (ref.mounted) {
        _load();
      }
    });
    return const TableBrowseState();
  }

  /// Replaces the filter set and reloads from the first page.
  void applyFilters(List<ColumnFilter> filters) {
    state = state.copyWith(filters: filters);
    _load();
  }

  /// Removes the filter at [index] and reloads.
  void removeFilterAt(int index) {
    final filters = <ColumnFilter>[...state.filters]..removeAt(index);
    applyFilters(filters);
  }

  /// Orders by [column], or clears the sort when [direction] is null.
  void sortBy(String column, SortDirection? direction) {
    state = direction == null
        ? state.copyWith(clearSort: true)
        : state.copyWith(
            sort: ColumnSort(column: column, direction: direction),
          );
    _load();
  }

  /// Re-runs the current query from the first page.
  Future<void> refresh() => _load();

  /// Fetches and appends the next page.
  Future<void> loadMore() async {
    final current = state;
    if (!current.canLoadMore || current.loadingMore || current.loading) {
      return;
    }
    state = current.copyWith(loadingMore: true);

    final adapter = ref.read(activeAdapterProvider);
    final query = adapter.buildTableQuery(
      schema: schema,
      table: table,
      filters: current.filters,
      sort: current.sort,
      limit: tableBrowsePageSize,
      offset: current.nextOffset,
    );

    try {
      final result = await adapter.execute(query.sql, params: query.params);
      if (!ref.mounted) {
        return;
      }
      state = current.copyWith(
        rows: <List<Object?>>[...current.rows, ...result.rows],
        nextOffset: current.nextOffset + tableBrowsePageSize,
        canLoadMore: result.rows.length == tableBrowsePageSize,
        loadingMore: false,
      );
    } on AppException {
      if (!ref.mounted) {
        return;
      }
      // Keep the rows we already have; just stop offering more.
      state = current.copyWith(loadingMore: false, canLoadMore: false);
    }
  }

  Future<void> _load() async {
    state = state.copyWith(loading: true, clearError: true);
    final adapter = ref.read(activeAdapterProvider);
    final query = adapter.buildTableQuery(
      schema: schema,
      table: table,
      filters: state.filters,
      sort: state.sort,
      limit: tableBrowsePageSize,
    );

    try {
      final result = await adapter.execute(query.sql, params: query.params);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        columns: result.columns,
        rows: result.rows,
        elapsed: result.elapsed,
        queryId: ++_queryCounter,
        loading: false,
        nextOffset: tableBrowsePageSize,
        canLoadMore: result.rows.length == tableBrowsePageSize,
      );
    } on AppException catch (error) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        loading: false,
        canLoadMore: false,
        rows: const <List<Object?>>[],
        error: error,
      );
    }
  }
}
