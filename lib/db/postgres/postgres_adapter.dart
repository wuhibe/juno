import 'package:juno/db/adapter/database_adapter.dart';
import 'package:juno/db/adapter/models/column_meta.dart';
import 'package:juno/db/adapter/models/connection_config.dart';
import 'package:juno/db/adapter/models/query_result.dart';
import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:juno/db/postgres/postgres_error_mapper.dart';
import 'package:juno/db/postgres/postgres_introspection.dart';
import 'package:postgres/postgres.dart' as pg;

/// The PostgreSQL implementation of [DatabaseAdapter].
///
/// This is the **only** place `package:postgres` is imported. It owns the
/// connection lifecycle, maps driver results/errors onto driver-agnostic models
/// and typed [AppException]s, and enforces read-only mode server-side (plan §4).
class PostgresAdapter implements DatabaseAdapter {
  /// Creates an unconnected adapter.
  PostgresAdapter();

  final PostgresIntrospection _introspection = const PostgresIntrospection();

  pg.Connection? _connection;
  // Retained so [cancelRunning] can open a second connection to issue the
  // cancel request, and so we never keep the password beyond [connect].
  pg.Endpoint? _endpoint;
  pg.ConnectionSettings? _settings;
  int? _backendPid;

  @override
  DatabaseKind get kind => DatabaseKind.postgres;

  @override
  bool get isConnected => _connection != null && _connection!.isOpen;

  @override
  Future<void> connect(ConnectionConfig config) async {
    await disconnect();

    final endpoint = pg.Endpoint(
      host: config.host,
      port: config.port,
      database: config.database,
      username: config.username,
      password: config.password,
    );
    final settings = pg.ConnectionSettings(
      sslMode: _mapSslMode(config.sslMode),
      connectTimeout: config.connectTimeout,
      queryTimeout: config.queryTimeout,
    );

    try {
      final connection = await pg.Connection.open(endpoint, settings: settings);
      _connection = connection;
      _endpoint = endpoint;
      _settings = settings;

      if (config.readOnly) {
        // Layer 1 — the actual guarantee. Postgres rejects every write
        // (including ones hidden in CTEs) at the engine level (plan §4).
        await connection.execute('SET default_transaction_read_only = on');
        await connection.execute(
          'SET SESSION CHARACTERISTICS AS TRANSACTION READ ONLY',
        );
      }

      // Remember the backend PID so cancellation can target this session.
      final pidResult = await connection.execute('SELECT pg_backend_pid()');
      _backendPid = pidResult.first.first! as int;
    } catch (error, stackTrace) {
      await _closeQuietly();
      _connection = null;
      throw mapPostgresError(error, stackTrace);
    }
  }

  @override
  Future<void> disconnect() async {
    await _closeQuietly();
    _connection = null;
    _endpoint = null;
    _settings = null;
    _backendPid = null;
  }

  @override
  Future<Duration> ping() async {
    final connection = _requireConnection();
    final stopwatch = Stopwatch()..start();
    try {
      await connection.execute('SELECT 1');
    } catch (error, stackTrace) {
      throw mapPostgresError(error, stackTrace);
    }
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  @override
  Future<QueryResult> execute(
    String sql, {
    Map<String, Object?>? params,
    Duration? timeout,
  }) async {
    final connection = _requireConnection();
    final stopwatch = Stopwatch()..start();
    try {
      final pg.Result result;
      if (params != null && params.isNotEmpty) {
        result = await connection.execute(
          pg.Sql.named(sql),
          parameters: params,
          timeout: timeout,
        );
      } else {
        result = await connection.execute(sql, timeout: timeout);
      }
      stopwatch.stop();
      return _toQueryResult(result, stopwatch.elapsed);
    } catch (error, stackTrace) {
      throw mapPostgresError(error, stackTrace, sql: sql);
    }
  }

  @override
  Future<void> cancelRunning() async {
    final pid = _backendPid;
    final endpoint = _endpoint;
    final settings = _settings;
    if (pid == null || endpoint == null || settings == null) {
      return;
    }
    try {
      // A cancel request must come from a *different* connection.
      final canceller = await pg.Connection.open(endpoint, settings: settings);
      try {
        await canceller.execute(
          pg.Sql.named('SELECT pg_cancel_backend(@pid)'),
          parameters: <String, Object?>{'pid': pid},
        );
      } finally {
        await canceller.close();
      }
    } catch (_) {
      // Best-effort only (plan §3): a failed cancel must not surface an error.
    }
  }

  @override
  Future<List<DbSchema>> listSchemas({bool includeSystem = false}) async {
    final connection = _requireConnection();
    try {
      return await _introspection.listSchemas(
        connection,
        includeSystem: includeSystem,
      );
    } catch (error, stackTrace) {
      throw mapPostgresError(error, stackTrace);
    }
  }

  @override
  Future<List<DbTable>> listTables(String schema) async {
    final connection = _requireConnection();
    try {
      return await _introspection.listTables(connection, schema);
    } catch (error, stackTrace) {
      throw mapPostgresError(error, stackTrace);
    }
  }

  @override
  Future<List<DbColumn>> listColumns(String schema, String table) async {
    final connection = _requireConnection();
    try {
      return await _introspection.listColumns(connection, schema, table);
    } catch (error, stackTrace) {
      throw mapPostgresError(error, stackTrace);
    }
  }

  @override
  String quoteIdentifier(String raw) => '"${raw.replaceAll('"', '""')}"';

  @override
  String limitClause(int limit, int offset) =>
      offset > 0 ? 'LIMIT $limit OFFSET $offset' : 'LIMIT $limit';

  // --- internals ---

  pg.Connection _requireConnection() {
    final connection = _connection;
    if (connection == null) {
      throw StateError('Not connected. Call connect() before querying.');
    }
    return connection;
  }

  Future<void> _closeQuietly() async {
    final connection = _connection;
    if (connection == null) {
      return;
    }
    try {
      await connection.close();
    } catch (_) {
      // Best-effort close; the socket may already be gone.
    }
  }

  QueryResult _toQueryResult(pg.Result result, Duration elapsed) {
    final columns = <ColumnMeta>[
      for (final column in result.schema.columns)
        ColumnMeta(
          name: column.columnName ?? '?column?',
          dbType: _typeName(column.typeOid),
          typeOid: column.typeOid,
        ),
    ];
    final rows = <List<Object?>>[
      for (final row in result) List<Object?>.from(row),
    ];
    return QueryResult(
      columns: columns,
      rows: rows,
      affectedRows: result.affectedRows,
      elapsed: elapsed,
    );
  }

  pg.SslMode _mapSslMode(DbSslMode mode) => switch (mode) {
    DbSslMode.disable => pg.SslMode.disable,
    DbSslMode.require => pg.SslMode.require,
    DbSslMode.verifyFull => pg.SslMode.verifyFull,
  };

  /// Maps common Postgres type OIDs to readable names. Anything not listed
  /// falls back to `oid(<n>)`; a fuller per-OID value formatter arrives in
  /// Phase 5 (plan §9.5).
  String _typeName(int oid) => _pgTypeNames[oid] ?? 'oid($oid)';

  static const Map<int, String> _pgTypeNames = <int, String>{
    16: 'bool',
    17: 'bytea',
    18: 'char',
    19: 'name',
    20: 'int8',
    21: 'int2',
    23: 'int4',
    25: 'text',
    26: 'oid',
    114: 'json',
    700: 'float4',
    701: 'float8',
    1042: 'bpchar',
    1043: 'varchar',
    1082: 'date',
    1083: 'time',
    1114: 'timestamp',
    1184: 'timestamptz',
    1186: 'interval',
    1700: 'numeric',
    2950: 'uuid',
    3802: 'jsonb',
    1000: '_bool',
    1009: '_text',
    1007: '_int4',
    1016: '_int8',
  };
}
