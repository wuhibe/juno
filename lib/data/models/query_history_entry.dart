/// A single local query-history record (domain model).
///
/// Stores SQL text only — never result data, and never credentials (plan §5).
class QueryHistoryEntry {
  /// Creates a history entry. [id] is null until persisted.
  const QueryHistoryEntry({
    required this.connectionId,
    required this.sqlText,
    required this.startedAt,
    required this.elapsedMs,
    required this.success,
    this.id,
    this.rowCount,
    this.errorSummary,
  });

  /// Auto-increment id, assigned on insert.
  final int? id;

  /// The connection this query ran against.
  final String connectionId;

  /// The SQL that was executed.
  final String sqlText;

  /// When execution started.
  final DateTime startedAt;

  /// Server round-trip time, in milliseconds.
  final int elapsedMs;

  /// Rows returned, when known.
  final int? rowCount;

  /// Whether the statement succeeded.
  final bool success;

  /// Short, user-safe error summary when [success] is false.
  final String? errorSummary;

  @override
  String toString() =>
      'QueryHistoryEntry($connectionId, ${success ? 'ok' : 'error'}, '
      '${elapsedMs}ms)';
}
