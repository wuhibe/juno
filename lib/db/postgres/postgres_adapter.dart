import 'dart:convert';

import 'package:juno/db/adapter/database_adapter.dart';
import 'package:juno/db/adapter/models/column_meta.dart';
import 'package:juno/db/adapter/models/connection_config.dart';
import 'package:juno/db/adapter/models/query_result.dart';
import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:juno/db/adapter/models/table_query.dart';
import 'package:juno/db/postgres/postgres_error_mapper.dart';
import 'package:juno/db/postgres/postgres_introspection.dart';
import 'package:postgres/postgres.dart' as pg;

/// The PostgreSQL implementation of [DatabaseAdapter].
///
/// This is the **only** place `package:postgres` is imported. It owns the
/// connection lifecycle, maps driver results/errors onto driver-agnostic models
/// and typed [AppException]s, and enforces read-only mode server-side.
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

  /// OID → name for this database's enum types. The driver has no codec for
  /// user-defined OIDs, so without this an enum column reports `oid(16xxx)` and
  /// its values arrive as raw bytes.
  Map<int, String> _enumTypeNames = const <int, String>{};

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
        // (including ones hidden in CTEs) at the engine level.
        await connection.execute('SET default_transaction_read_only = on');
        await connection.execute(
          'SET SESSION CHARACTERISTICS AS TRANSACTION READ ONLY',
        );
      }

      // Remember the backend PID so cancellation can target this session.
      final pidResult = await connection.execute('SELECT pg_backend_pid()');
      _backendPid = pidResult.first.first! as int;

      _enumTypeNames = await _loadEnumTypeNames(connection);
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
    _enumTypeNames = const <int, String>{};
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
      // Best-effort only: a failed cancel must not surface an error.
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

  @override
  ({String sql, Map<String, Object?> params}) buildTableQuery({
    required String schema,
    required String table,
    required int limit,
    List<ColumnFilter> filters = const <ColumnFilter>[],
    ColumnSort? sort,
    int offset = 0,
  }) {
    final params = <String, Object?>{};
    final conditions = <String>[];

    for (var i = 0; i < filters.length; i++) {
      final filter = filters[i];
      final column = quoteIdentifier(filter.column);
      if (!filter.isComplete) {
        throw ArgumentError.value(
          filter,
          'filters',
          'operator ${filter.op.name} needs a value',
        );
      }

      switch (filter.op) {
        case FilterOperator.isNull:
          conditions.add('$column IS NULL');
        case FilterOperator.isNotNull:
          conditions.add('$column IS NOT NULL');
        case FilterOperator.contains:
        case FilterOperator.startsWith:
          // ::text casts so the match also works on enums (which have no LIKE
          // operator), numerics, and timestamps.
          final pattern = _likeEscape(filter.values.first);
          params['f$i'] = filter.op == FilterOperator.contains
              ? '%$pattern%'
              : '$pattern%';
          conditions.add("$column::text ILIKE @f$i ESCAPE '\\'");
        case FilterOperator.inList:
          // Expanded rather than `= ANY(@f$i)`: an array parameter goes out
          // untyped, and the server cannot infer its element type against an
          // enum column.
          final alternatives = <String>[];
          for (var v = 0; v < filter.values.length; v++) {
            params['f${i}_$v'] = filter.values[v];
            alternatives.add('$column = @f${i}_$v');
          }
          conditions.add('(${alternatives.join(' OR ')})');
        case FilterOperator.eq:
        case FilterOperator.notEq:
        case FilterOperator.gt:
        case FilterOperator.gte:
        case FilterOperator.lt:
        case FilterOperator.lte:
          params['f$i'] = filter.values.first;
          conditions.add('$column ${_comparisonOperators[filter.op]} @f$i');
      }
    }

    final buffer = StringBuffer(
      'SELECT * FROM ${quoteIdentifier(schema)}.${quoteIdentifier(table)}',
    );
    if (conditions.isNotEmpty) {
      buffer.write(' WHERE ${conditions.join(' AND ')}');
    }
    if (sort != null) {
      final direction = sort.direction == SortDirection.asc ? 'ASC' : 'DESC';
      // Ties are ordered by whatever the server returns, so rows with equal
      // keys can shuffle between pages. Fine for browsing; a unique tiebreaker
      // would need the table's primary key.
      buffer.write(' ORDER BY ${quoteIdentifier(sort.column)} $direction');
    }
    buffer.write(' ${limitClause(limit, offset)}');

    return (sql: buffer.toString(), params: params);
  }

  static const Map<FilterOperator, String> _comparisonOperators =
      <FilterOperator, String>{
        FilterOperator.eq: '=',
        FilterOperator.notEq: '<>',
        FilterOperator.gt: '>',
        FilterOperator.gte: '>=',
        FilterOperator.lt: '<',
        FilterOperator.lte: '<=',
      };

  /// Escapes the LIKE wildcards so a user's `%` or `_` matches literally.
  String _likeEscape(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');

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

  /// Loads the database's enum types. Best-effort: a role without `pg_type`
  /// visibility still gets a working connection, just `oid(n)` type labels.
  Future<Map<int, String>> _loadEnumTypeNames(pg.Session session) async {
    try {
      final result = await session.execute(
        "SELECT oid, typname FROM pg_catalog.pg_type WHERE typtype = 'e'",
      );
      return <int, String>{
        for (final row in result) row[0]! as int: row[1]! as String,
      };
    } catch (_) {
      return const <int, String>{};
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
      for (final row in result)
        <Object?>[for (final cell in row) _decode(cell)],
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

  /// Converts a driver value the registry could not decode into something the
  /// driver-agnostic layers can render.
  ///
  /// The driver has no codec for user-defined OIDs (enums, domains, composites,
  /// extension types) and hands back [pg.UndecodedBytes]. That type must never
  /// escape the adapter — the UI would render `Instance of 'UndecodedBytes'`.
  /// Enums and every other text-shaped type decode as UTF-8; genuinely binary
  /// payloads fall back to the `\x…` hex form the cell formatter already uses
  /// for bytea.
  Object? _decode(Object? value) {
    if (value is! pg.UndecodedBytes) {
      return value;
    }
    try {
      return const Utf8Decoder().convert(value.bytes);
    } on FormatException {
      return value.bytes;
    }
  }

  /// Maps Postgres type OIDs to readable names: the built-in table first, then
  /// this database's enum types, else `oid(<n>)`.
  String _typeName(int oid) =>
      _pgTypeNames[oid] ?? _enumTypeNames[oid] ?? 'oid($oid)';

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
