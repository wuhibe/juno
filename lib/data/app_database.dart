import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Saved connection metadata. **Never** stores secrets — passwords live only in
/// secure storage (see `SecureCredentialsRepository`).
@DataClassName('ConnectionRow')
class Connections extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// User-facing name.
  TextColumn get name => text()();

  /// `DatabaseKind.name` (persisted from day one for multi-engine support).
  TextColumn get kind => text()();

  /// Hostname or IP.
  TextColumn get host => text()();

  /// TCP port.
  IntColumn get port => integer()();

  /// Database/catalog name.
  TextColumn get database => text()();

  /// Login role.
  TextColumn get username => text()();

  /// `DbSslMode.name`.
  TextColumn get sslMode => text()();

  /// Whether the connection enforces read-only mode.
  BoolColumn get readOnly => boolean().withDefault(const Constant(true))();

  /// Optional color tag (hex or named) for the connection card.
  TextColumn get colorTag => text().nullable()();

  /// Optional `DbEnvironment.name` (dev/staging/prod).
  TextColumn get environment => text().nullable()();

  /// Manual ordering within the list.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// When the connection was created.
  DateTimeColumn get createdAt => dateTime()();

  /// When the connection was last successfully opened.
  DateTimeColumn get lastUsedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Local query history (SQL text only — never result data or credentials).
/// Capped per connection (see `QueryHistoryRepository`).
@DataClassName('QueryHistoryRow')
class QueryHistoryEntries extends Table {
  /// Auto-increment primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Owning connection; rows cascade-delete with the connection.
  TextColumn get connectionId =>
      text().references(Connections, #id, onDelete: KeyAction.cascade)();

  /// The SQL that was run.
  TextColumn get sqlText => text()();

  /// When execution started.
  DateTimeColumn get startedAt => dateTime()();

  /// Server round-trip time, in milliseconds.
  IntColumn get elapsedMs => integer()();

  /// Rows returned, when known.
  IntColumn get rowCount => integer().nullable()();

  /// Whether the statement succeeded.
  BoolColumn get success => boolean()();

  /// A short, user-safe error summary when [success] is false.
  TextColumn get errorSummary => text().nullable()();
}

/// Snippet chips the user has pinned to the editor toolbar's favorites group.
/// Identified by the chip's label.
@DataClassName('SnippetFavoriteRow')
class SnippetFavorites extends Table {
  /// The pinned chip's label (e.g. `SELECT`, `WHERE`).
  TextColumn get label => text()();

  /// Ordering within the favorites group (lower = earlier).
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{label};
}

/// The app's local SQLite database (saved connections + query history +
/// pinned snippet favorites).
@DriftDatabase(
  tables: <Type>[Connections, QueryHistoryEntries, SnippetFavorites],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the on-device database (production), or wraps an injected
  /// [executor] (e.g. an in-memory database in tests).
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'juno'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(snippetFavorites);
      }
    },
    beforeOpen: (details) async {
      // Required for the query_history -> connections cascade delete.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
