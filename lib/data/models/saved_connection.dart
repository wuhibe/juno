import 'package:juno/db/adapter/models/connection_config.dart';

/// The deployment environment a connection points at. Drives the color/badge
/// treatment in the UI (prod gets a red accent).
enum DbEnvironment {
  /// Development.
  dev,

  /// Staging / pre-production.
  staging,

  /// Production (treated with extra caution in the UI).
  prod,
}

/// A persisted connection's non-secret metadata — the domain model the app
/// works with, decoupled from the drift row type.
///
/// The password is never part of this model; it lives only in secure storage.
/// Use [toConnectionConfig] to assemble the transient [ConnectionConfig] for the
/// adapter, supplying the password fetched from secure storage at connect time.
class SavedConnection {
  /// Creates a saved-connection record.
  const SavedConnection({
    required this.id,
    required this.name,
    required this.host,
    required this.database,
    required this.username,
    required this.createdAt,
    this.kind = DatabaseKind.postgres,
    this.port = 5432,
    this.sslMode = DbSslMode.require,
    this.readOnly = true,
    this.colorTag,
    this.environment,
    this.sortOrder = 0,
    this.lastUsedAt,
  });

  /// UUID primary key.
  final String id;

  /// User-facing name.
  final String name;

  /// Target engine.
  final DatabaseKind kind;

  /// Hostname or IP.
  final String host;

  /// TCP port.
  final int port;

  /// Database/catalog name.
  final String database;

  /// Login role.
  final String username;

  /// How TLS is negotiated.
  final DbSslMode sslMode;

  /// Whether the connection enforces read-only mode.
  final bool readOnly;

  /// Optional color tag for the connection card.
  final String? colorTag;

  /// Optional deployment environment.
  final DbEnvironment? environment;

  /// Manual ordering within the list.
  final int sortOrder;

  /// When the connection was created.
  final DateTime createdAt;

  /// When the connection was last successfully opened.
  final DateTime? lastUsedAt;

  /// Whether this connection points at a production environment.
  bool get isProd => environment == DbEnvironment.prod;

  /// Builds the transient adapter config, injecting the [password] retrieved
  /// from secure storage. The password is never stored on this model.
  ConnectionConfig toConnectionConfig({required String password}) {
    return ConnectionConfig(
      kind: kind,
      host: host,
      port: port,
      database: database,
      username: username,
      password: password,
      sslMode: sslMode,
      readOnly: readOnly,
    );
  }

  /// Returns a copy with the given fields replaced.
  SavedConnection copyWith({
    String? id,
    String? name,
    DatabaseKind? kind,
    String? host,
    int? port,
    String? database,
    String? username,
    DbSslMode? sslMode,
    bool? readOnly,
    String? colorTag,
    DbEnvironment? environment,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    return SavedConnection(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      host: host ?? this.host,
      port: port ?? this.port,
      database: database ?? this.database,
      username: username ?? this.username,
      sslMode: sslMode ?? this.sslMode,
      readOnly: readOnly ?? this.readOnly,
      colorTag: colorTag ?? this.colorTag,
      environment: environment ?? this.environment,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  @override
  String toString() =>
      'SavedConnection($id, $name, $username@$host:$port/$database, '
      'readOnly: $readOnly)';
}
