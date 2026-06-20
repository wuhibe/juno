/// The database engine a connection targets.
///
/// Only [postgres] exists in v1, but the value is modeled — and persisted —
/// from day one so MySQL/SQLite adapters can be added later without a storage
/// or UI migration (see plan §3).
enum DatabaseKind {
  /// PostgreSQL.
  postgres,
  // Reserved for later: mysql, mariadb, sqlite.
}

/// How TLS is negotiated for a connection.
///
/// Driver-agnostic: each adapter maps these onto its own driver's SSL options.
enum DbSslMode {
  /// No TLS. The password may be sent in cleartext.
  disable,

  /// Require TLS, but do not verify the server certificate (accepts self-signed).
  require,

  /// Require TLS and verify the certificate chain and hostname.
  verifyFull,
}

/// Everything an adapter needs to open a connection.
///
/// This is a **transient** object assembled at connect time — the [password] is
/// fetched from secure storage and lives here only in memory. It is never
/// persisted to drift, logs, analytics, or error reports; [toString] redacts it.
/// Non-secret connection metadata is stored separately (see plan §5).
class ConnectionConfig {
  /// Creates a connection configuration.
  const ConnectionConfig({
    required this.host,
    required this.database,
    required this.username,
    required this.password,
    this.kind = DatabaseKind.postgres,
    this.port = 5432,
    this.sslMode = DbSslMode.require,
    this.readOnly = true,
    this.connectTimeout = const Duration(seconds: 10),
    this.queryTimeout = const Duration(seconds: 60),
  });

  /// The target engine.
  final DatabaseKind kind;

  /// Hostname or IP of the database server.
  final String host;

  /// TCP port (Postgres default 5432).
  final int port;

  /// The database/catalog name to connect to.
  final String database;

  /// The role/username to authenticate as.
  final String username;

  /// The secret used to authenticate. Transient and never persisted/logged.
  final String password;

  /// How TLS is negotiated.
  final DbSslMode sslMode;

  /// When true, the adapter enforces read-only mode server-side (plan §4).
  final bool readOnly;

  /// Maximum time to wait for the initial connection.
  final Duration connectTimeout;

  /// Default per-statement timeout.
  final Duration queryTimeout;

  /// Returns a copy with the given fields replaced.
  ConnectionConfig copyWith({
    DatabaseKind? kind,
    String? host,
    int? port,
    String? database,
    String? username,
    String? password,
    DbSslMode? sslMode,
    bool? readOnly,
    Duration? connectTimeout,
    Duration? queryTimeout,
  }) {
    return ConnectionConfig(
      kind: kind ?? this.kind,
      host: host ?? this.host,
      port: port ?? this.port,
      database: database ?? this.database,
      username: username ?? this.username,
      password: password ?? this.password,
      sslMode: sslMode ?? this.sslMode,
      readOnly: readOnly ?? this.readOnly,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      queryTimeout: queryTimeout ?? this.queryTimeout,
    );
  }

  @override
  String toString() {
    return 'ConnectionConfig(kind: $kind, host: $host, port: $port, '
        'database: $database, username: $username, password: <redacted>, '
        'sslMode: $sslMode, readOnly: $readOnly)';
  }
}
