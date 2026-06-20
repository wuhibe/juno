import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juno/data/app_database.dart';
import 'package:juno/data/connections_repository.dart';
import 'package:juno/data/models/query_history_entry.dart';
import 'package:juno/data/models/saved_connection.dart';
import 'package:juno/data/query_history_repository.dart';
import 'package:juno/data/secure_credentials_repository.dart';

class _InMemoryCredentials implements SecureCredentialsRepository {
  @override
  Future<void> savePassword(String connectionId, String password) async {}

  @override
  Future<String?> readPassword(String connectionId) async => null;

  @override
  Future<void> deletePassword(String connectionId) async {}
}

QueryHistoryEntry _entry(String connId, {DateTime? at, bool success = true}) =>
    QueryHistoryEntry(
      connectionId: connId,
      sqlText: 'SELECT 1',
      startedAt: at ?? DateTime(2026, 1, 1),
      elapsedMs: 5,
      success: success,
      rowCount: 1,
    );

void main() {
  late AppDatabase db;
  late QueryHistoryRepository history;
  late ConnectionsRepository connections;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    history = QueryHistoryRepository(db);
    connections = ConnectionsRepository(db, _InMemoryCredentials());
    await connections.create(
      SavedConnection(
        id: 'c1',
        name: 'c1',
        host: 'h',
        database: 'd',
        username: 'u',
        createdAt: DateTime(2026),
      ),
      password: 'x',
    );
  });
  tearDown(() => db.close());

  test('record then watch returns the entry', () async {
    await history.record(_entry('c1'));

    final list = await history.watchForConnection('c1').first;
    expect(list, hasLength(1));
    expect(list.single.sqlText, 'SELECT 1');
  });

  test('trims to maxPerConnection on insert', () async {
    final base = DateTime(2026, 1, 1);
    for (var i = 0; i < QueryHistoryRepository.maxPerConnection + 5; i++) {
      await history.record(_entry('c1', at: base.add(Duration(seconds: i))));
    }

    final list = await history.watchForConnection('c1').first;
    expect(list, hasLength(QueryHistoryRepository.maxPerConnection));
  });

  test('history cascade-deletes with its connection', () async {
    await history.record(_entry('c1'));

    await connections.delete('c1');

    final list = await history.watchForConnection('c1').first;
    expect(list, isEmpty);
  });
}
