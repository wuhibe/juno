import 'package:juno/data/app_database.dart';
import 'package:juno/data/connections_repository.dart';
import 'package:juno/data/models/saved_connection.dart';
import 'package:juno/data/query_history_repository.dart';
import 'package:juno/data/secure_credentials_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_providers.g.dart';

/// The app's local database. Kept alive for the app's lifetime; closed on dispose.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

/// Secure storage for connection passwords.
@Riverpod(keepAlive: true)
SecureCredentialsRepository secureCredentialsRepository(Ref ref) =>
    FlutterSecureCredentialsRepository();

/// Repository for saved connections.
@Riverpod(keepAlive: true)
ConnectionsRepository connectionsRepository(Ref ref) => ConnectionsRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(secureCredentialsRepositoryProvider),
);

/// Repository for query history.
@Riverpod(keepAlive: true)
QueryHistoryRepository queryHistoryRepository(Ref ref) =>
    QueryHistoryRepository(ref.watch(appDatabaseProvider));

/// Live list of saved connections for the connection manager.
@riverpod
Stream<List<SavedConnection>> connectionsList(Ref ref) =>
    ref.watch(connectionsRepositoryProvider).watchAll();
