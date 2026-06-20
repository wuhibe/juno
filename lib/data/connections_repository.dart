import 'package:drift/drift.dart';
import 'package:juno/data/app_database.dart';
import 'package:juno/data/models/saved_connection.dart';
import 'package:juno/data/secure_credentials_repository.dart';
import 'package:juno/db/adapter/models/connection_config.dart';
import 'package:uuid/uuid.dart';

/// CRUD for saved connections.
///
/// Owns the invariant that a connection's password lives in secure storage and
/// is created/deleted in lockstep with the connection row. Query-history rows
/// cascade-delete with the connection at the database level.
class ConnectionsRepository {
  /// Creates the repository over [_db] and [_credentials].
  ConnectionsRepository(this._db, this._credentials, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final SecureCredentialsRepository _credentials;
  final Uuid _uuid;

  /// Watches all connections, ordered by [SavedConnection.sortOrder] then
  /// creation time. Emits a new list whenever the table changes.
  Stream<List<SavedConnection>> watchAll() {
    final query = _db.select(_db.connections)
      ..orderBy(<OrderClauseGenerator<$ConnectionsTable>>[
        (t) => OrderingTerm(expression: t.sortOrder),
        (t) => OrderingTerm(expression: t.createdAt),
      ]);
    return query.watch().map(
      (rows) => rows.map(_fromRow).toList(growable: false),
    );
  }

  /// Returns all connections (one-shot).
  Future<List<SavedConnection>> getAll() async {
    final rows = await _db.select(_db.connections).get();
    return rows.map(_fromRow).toList(growable: false);
  }

  /// Returns the connection with [id], or null.
  Future<SavedConnection?> getById(String id) async {
    final row = await (_db.select(
      _db.connections,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  /// Inserts [connection] and stores its [password] in secure storage.
  Future<void> create(
    SavedConnection connection, {
    required String password,
  }) async {
    await _db.into(_db.connections).insert(_toRow(connection));
    await _credentials.savePassword(connection.id, password);
  }

  /// Updates [connection]; replaces the stored password only if [password] is
  /// provided (null leaves the existing secret untouched).
  Future<void> update(SavedConnection connection, {String? password}) async {
    await _db.update(_db.connections).replace(_toRow(connection));
    if (password != null) {
      await _credentials.savePassword(connection.id, password);
    }
  }

  /// Deletes the connection, its secret, and (via cascade) its history.
  Future<void> delete(String id) async {
    await (_db.delete(_db.connections)..where((t) => t.id.equals(id))).go();
    await _credentials.deletePassword(id);
  }

  /// Duplicates [id] into a new connection (new UUID, "(copy)" suffix), copying
  /// the stored password. Returns the new record, or null if [id] is unknown.
  Future<SavedConnection?> duplicate(String id) async {
    final original = await getById(id);
    if (original == null) {
      return null;
    }
    final copy = original.copyWith(
      id: _uuid.v4(),
      name: '${original.name} (copy)',
      createdAt: DateTime.now(),
      lastUsedAt: null,
    );
    final password = await _credentials.readPassword(id) ?? '';
    await create(copy, password: password);
    return copy;
  }

  /// Stamps [id] as just used (updates `lastUsedAt`).
  Future<void> markUsed(String id) async {
    await (_db.update(_db.connections)..where((t) => t.id.equals(id))).write(
      ConnectionsCompanion(lastUsedAt: Value(DateTime.now())),
    );
  }

  SavedConnection _fromRow(ConnectionRow row) => SavedConnection(
    id: row.id,
    name: row.name,
    kind: DatabaseKind.values.byName(row.kind),
    host: row.host,
    port: row.port,
    database: row.database,
    username: row.username,
    sslMode: DbSslMode.values.byName(row.sslMode),
    readOnly: row.readOnly,
    colorTag: row.colorTag,
    environment: row.environment == null
        ? null
        : DbEnvironment.values.byName(row.environment!),
    sortOrder: row.sortOrder,
    createdAt: row.createdAt,
    lastUsedAt: row.lastUsedAt,
  );

  ConnectionRow _toRow(SavedConnection c) => ConnectionRow(
    id: c.id,
    name: c.name,
    kind: c.kind.name,
    host: c.host,
    port: c.port,
    database: c.database,
    username: c.username,
    sslMode: c.sslMode.name,
    readOnly: c.readOnly,
    colorTag: c.colorTag,
    environment: c.environment?.name,
    sortOrder: c.sortOrder,
    createdAt: c.createdAt,
    lastUsedAt: c.lastUsedAt,
  );
}
