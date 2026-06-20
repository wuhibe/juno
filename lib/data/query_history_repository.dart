import 'package:drift/drift.dart';

import 'package:juno/data/app_database.dart';
import 'package:juno/data/models/query_history_entry.dart';

/// Local query-history storage, capped per connection.
class QueryHistoryRepository {
  /// Creates the repository over [_db].
  QueryHistoryRepository(this._db);

  final AppDatabase _db;

  /// Maximum entries retained per connection; older rows are trimmed on insert.
  static const int maxPerConnection = 500;

  /// Records [entry] and trims the connection's history to [maxPerConnection].
  /// Returns the new row id.
  Future<int> record(QueryHistoryEntry entry) async {
    final id = await _db
        .into(_db.queryHistoryEntries)
        .insert(
          QueryHistoryEntriesCompanion.insert(
            connectionId: entry.connectionId,
            sqlText: entry.sqlText,
            startedAt: entry.startedAt,
            elapsedMs: entry.elapsedMs,
            success: entry.success,
            rowCount: Value(entry.rowCount),
            errorSummary: Value(entry.errorSummary),
          ),
        );
    await _trim(entry.connectionId);
    return id;
  }

  /// Watches a connection's history, newest first.
  Stream<List<QueryHistoryEntry>> watchForConnection(String connectionId) {
    final query = _db.select(_db.queryHistoryEntries)
      ..where((t) => t.connectionId.equals(connectionId))
      ..orderBy(<OrderClauseGenerator<$QueryHistoryEntriesTable>>[
        (t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ]);
    return query.watch().map(
      (rows) => rows.map(_fromRow).toList(growable: false),
    );
  }

  /// Deletes all history for [connectionId].
  Future<void> clearForConnection(String connectionId) {
    return (_db.delete(
      _db.queryHistoryEntries,
    )..where((t) => t.connectionId.equals(connectionId))).go();
  }

  Future<void> _trim(String connectionId) async {
    await _db.customStatement(
      'DELETE FROM query_history_entries '
      'WHERE connection_id = ? AND id NOT IN ('
      '  SELECT id FROM query_history_entries '
      '  WHERE connection_id = ? '
      '  ORDER BY started_at DESC, id DESC LIMIT ?'
      ')',
      <Object?>[connectionId, connectionId, maxPerConnection],
    );
  }

  QueryHistoryEntry _fromRow(QueryHistoryRow row) => QueryHistoryEntry(
    id: row.id,
    connectionId: row.connectionId,
    sqlText: row.sqlText,
    startedAt: row.startedAt,
    elapsedMs: row.elapsedMs,
    rowCount: row.rowCount,
    success: row.success,
    errorSummary: row.errorSummary,
  );
}
