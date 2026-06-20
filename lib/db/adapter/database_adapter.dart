import 'package:juno/db/adapter/models/connection_config.dart';
import 'package:juno/db/adapter/models/query_result.dart';
import 'package:juno/db/adapter/models/schema_objects.dart';

/// The contract every database driver implements.
///
/// This is the single seam that keeps Juno multi-engine: the UI, state, and
/// repository layers depend only on this interface and the driver-agnostic
/// models — never on `package:postgres` or any other driver. All SQL the app
/// itself generates (previews, pagination, introspection) lives inside the
/// concrete adapter (see plan §3).
abstract interface class DatabaseAdapter {
  /// The engine this adapter speaks to.
  DatabaseKind get kind;

  /// Whether a connection is currently open.
  bool get isConnected;

  /// Opens the connection described by [config].
  ///
  /// MUST honor [ConnectionConfig.readOnly] by enforcing it server-side where
  /// the engine supports it (Postgres: `default_transaction_read_only`; plan §4).
  /// Throws an `AppException` subtype on failure.
  Future<void> connect(ConnectionConfig config);

  /// Closes the connection and releases resources. Safe to call when not open.
  Future<void> disconnect();

  /// A cheap liveness probe (e.g. `SELECT 1`); returns the round-trip time.
  Future<Duration> ping();

  /// Executes arbitrary [sql], optionally with named [params] (`@name`).
  ///
  /// [timeout] overrides the connection's default statement timeout. Throws a
  /// typed `AppException` (never a raw driver error) on failure.
  Future<QueryResult> execute(
    String sql, {
    Map<String, Object?>? params,
    Duration? timeout,
  });

  /// Best-effort cancellation of the currently running statement.
  Future<void> cancelRunning();

  /// Lists schemas. System schemas are excluded unless [includeSystem] is true.
  Future<List<DbSchema>> listSchemas({bool includeSystem = false});

  /// Lists tables, views, and materialized views in [schema].
  Future<List<DbTable>> listTables(String schema);

  /// Lists columns of [schema].[table], including nullability, PK, and FK info.
  Future<List<DbColumn>> listColumns(String schema, String table);

  /// Quotes [raw] as an engine-specific identifier (Postgres: `"ident"`).
  String quoteIdentifier(String raw);

  /// Builds the engine-specific LIMIT/OFFSET clause for previews and pagination.
  String limitClause(int limit, int offset);
}
