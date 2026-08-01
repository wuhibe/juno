import 'package:juno/core/errors/app_exception.dart';
import 'package:juno/data/data_providers.dart';
import 'package:juno/data/models/query_history_entry.dart';
import 'package:juno/db/adapter/models/column_meta.dart';
import 'package:juno/features/connections/application/active_connection_provider.dart';
import 'package:juno/features/editor/domain/sql_statement.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'query_runner_provider.g.dart';

/// Rows fetched per page when a query is auto-paginated.
const int queryPageSize = 200;

/// Default per-statement timeout.
const Duration queryTimeout = Duration(seconds: 60);

/// State of the editor's query execution.
sealed class QueryRunState {
  const QueryRunState();
}

/// Nothing has been run yet.
class QueryRunIdle extends QueryRunState {
  /// Creates the idle state.
  const QueryRunIdle();
}

/// A statement is executing and can be cancelled.
class QueryRunning extends QueryRunState {
  /// Creates the running state.
  const QueryRunning(this.sql);

  /// The SQL being executed.
  final String sql;
}

/// A statement succeeded; [rows] accumulates across "load more" pages.
class QueryRunSuccess extends QueryRunState {
  /// Creates the success state.
  const QueryRunSuccess({
    required this.queryId,
    required this.sql,
    required this.columns,
    required this.rows,
    required this.affectedRows,
    required this.elapsed,
    required this.paginated,
    required this.nextOffset,
    required this.canLoadMore,
    required this.loadingMore,
  });

  /// Monotonic id; changes only for a brand-new query (not "load more"), so the
  /// grid can tell "fresh result" from "appended page".
  final int queryId;

  /// The originating SQL (without any appended pagination clause).
  final String sql;

  /// Result columns.
  final List<ColumnMeta> columns;

  /// Accumulated rows across all loaded pages.
  final List<List<Object?>> rows;

  /// Affected-row count for DML (0 for SELECTs).
  final int affectedRows;

  /// Elapsed time of the first page.
  final Duration elapsed;

  /// Whether the query was auto-paginated.
  final bool paginated;

  /// Offset for the next page.
  final int nextOffset;

  /// Whether another page is likely available.
  final bool canLoadMore;

  /// Whether a "load more" fetch is in flight.
  final bool loadingMore;

  /// Copies with the given fields replaced.
  QueryRunSuccess copyWith({
    List<List<Object?>>? rows,
    int? nextOffset,
    bool? canLoadMore,
    bool? loadingMore,
  }) {
    return QueryRunSuccess(
      queryId: queryId,
      sql: sql,
      columns: columns,
      rows: rows ?? this.rows,
      affectedRows: affectedRows,
      elapsed: elapsed,
      paginated: paginated,
      nextOffset: nextOffset ?? this.nextOffset,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

/// A statement failed (or was cancelled).
class QueryRunFailure extends QueryRunState {
  /// Creates the failure state.
  const QueryRunFailure(this.error, this.sql);

  /// The typed, user-safe error.
  final AppException error;

  /// The SQL that failed.
  final String sql;
}

/// Runs SQL against the active connection's adapter, applies the pagination
/// rule, supports cancel + "load more", and records each run in history.
@riverpod
class QueryRunner extends _$QueryRunner {
  int _queryCounter = 0;

  @override
  QueryRunState build() => const QueryRunIdle();

  /// Executes [sql]. A bare `SELECT` without its own `LIMIT` is fetched one
  /// [queryPageSize] page at a time; everything else runs verbatim.
  Future<void> run(String sql) async {
    final trimmed = sql.trim();
    if (trimmed.isEmpty) {
      state = const QueryRunIdle();
      return;
    }

    final adapter = ref.read(activeAdapterProvider);
    final statement = SqlStatement.classify(sql);
    final paginate = statement.isPaginable;
    final effectiveSql = paginate
        ? '${statement.normalized} ${adapter.limitClause(queryPageSize, 0)}'
        : sql;

    state = QueryRunning(sql);
    try {
      final result = await adapter.execute(effectiveSql, timeout: queryTimeout);
      final queryId = ++_queryCounter;
      state = QueryRunSuccess(
        queryId: queryId,
        sql: sql,
        columns: result.columns,
        rows: result.rows,
        affectedRows: result.affectedRows,
        elapsed: result.elapsed,
        paginated: paginate,
        nextOffset: queryPageSize,
        canLoadMore: paginate && result.rows.length == queryPageSize,
        loadingMore: false,
      );
      await _record(sql, success: true, rowCount: result.rowCount);
    } on AppException catch (error) {
      state = QueryRunFailure(error, sql);
      await _record(sql, success: false, errorSummary: error.message);
    }
  }

  /// Fetches and appends the next page of a paginated result.
  Future<void> loadMore() async {
    final current = state;
    if (current is! QueryRunSuccess ||
        !current.canLoadMore ||
        current.loadingMore) {
      return;
    }
    state = current.copyWith(loadingMore: true);

    final adapter = ref.read(activeAdapterProvider);
    final statement = SqlStatement.classify(current.sql);
    final pageSql =
        '${statement.normalized} '
        '${adapter.limitClause(queryPageSize, current.nextOffset)}';

    try {
      final result = await adapter.execute(pageSql, timeout: queryTimeout);
      state = current.copyWith(
        rows: <List<Object?>>[...current.rows, ...result.rows],
        nextOffset: current.nextOffset + queryPageSize,
        canLoadMore: result.rows.length == queryPageSize,
        loadingMore: false,
      );
    } on AppException {
      // Keep the rows we already have; just stop offering more.
      state = current.copyWith(loadingMore: false, canLoadMore: false);
    }
  }

  /// Best-effort cancellation of the running statement.
  Future<void> cancel() async {
    if (state is! QueryRunning) {
      return;
    }
    await ref.read(activeAdapterProvider).cancelRunning();
  }

  Future<void> _record(
    String sql, {
    required bool success,
    int? rowCount,
    String? errorSummary,
  }) async {
    final status = ref.read(activeConnectionProvider);
    if (status is! ConnectionConnected) {
      return;
    }
    final elapsed = switch (state) {
      QueryRunSuccess(:final elapsed) => elapsed,
      _ => Duration.zero,
    };
    await ref
        .read(queryHistoryRepositoryProvider)
        .record(
          QueryHistoryEntry(
            connectionId: status.connectionId,
            sqlText: sql,
            startedAt: DateTime.now(),
            elapsedMs: elapsed.inMilliseconds,
            rowCount: rowCount,
            success: success,
            errorSummary: errorSummary,
          ),
        );
  }
}
