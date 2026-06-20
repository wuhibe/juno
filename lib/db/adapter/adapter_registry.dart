import 'package:juno/db/adapter/database_adapter.dart';
import 'package:juno/db/adapter/models/connection_config.dart';
import 'package:juno/db/postgres/postgres_adapter.dart';

/// Builds a fresh [DatabaseAdapter].
typedef AdapterFactory = DatabaseAdapter Function();

/// Maps a persisted [DatabaseKind] to its concrete adapter.
///
/// This is the **one intentional reference** from the adapter package to a
/// concrete driver implementation — the composition seam that turns a stored
/// `DatabaseKind` into a live adapter. Driver code (`package:postgres`) stays
/// entirely within `db/postgres`. Adding MySQL later = one more factory here
/// plus a new adapter, with zero changes to UI/state/data layers.
abstract final class AdapterRegistry {
  static final Map<DatabaseKind, AdapterFactory> _factories =
      <DatabaseKind, AdapterFactory>{
        DatabaseKind.postgres: PostgresAdapter.new,
      };

  /// Creates a new adapter for [kind], or throws [UnsupportedError] if none is
  /// registered.
  static DatabaseAdapter create(DatabaseKind kind) {
    final factory = _factories[kind];
    if (factory == null) {
      throw UnsupportedError('No database adapter registered for $kind.');
    }
    return factory();
  }

  /// Whether an adapter is registered for [kind].
  static bool supports(DatabaseKind kind) => _factories.containsKey(kind);
}
