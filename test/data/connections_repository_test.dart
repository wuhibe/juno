import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juno/data/app_database.dart';
import 'package:juno/data/connections_repository.dart';
import 'package:juno/data/models/saved_connection.dart';
import 'package:juno/data/secure_credentials_repository.dart';
import 'package:juno/db/adapter/models/connection_config.dart';

/// In-memory credentials store so tests need no platform channels.
class _InMemoryCredentials implements SecureCredentialsRepository {
  final Map<String, String> store = <String, String>{};

  @override
  Future<void> savePassword(String connectionId, String password) async =>
      store[connectionId] = password;

  @override
  Future<String?> readPassword(String connectionId) async =>
      store[connectionId];

  @override
  Future<void> deletePassword(String connectionId) async =>
      store.remove(connectionId);
}

SavedConnection _sample(String id, {String name = 'Local'}) => SavedConnection(
  id: id,
  name: name,
  host: 'localhost',
  database: 'app',
  username: 'postgres',
  createdAt: DateTime(2026, 6, 20),
);

void main() {
  late AppDatabase db;
  late _InMemoryCredentials creds;
  late ConnectionsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    creds = _InMemoryCredentials();
    repo = ConnectionsRepository(db, creds);
  });
  tearDown(() => db.close());

  test('create persists metadata and stores the password separately', () async {
    await repo.create(_sample('a'), password: 's3cret');

    final got = await repo.getById('a');
    expect(got, isNotNull);
    expect(got!.name, 'Local');
    // The secret is never in the metadata store — only in secure storage.
    expect(creds.store['a'], 's3cret');
  });

  test('watchAll orders by sortOrder', () async {
    await repo.create(_sample('a').copyWith(sortOrder: 2), password: 'x');
    await repo.create(_sample('b').copyWith(sortOrder: 1), password: 'x');

    final list = await repo.watchAll().first;
    expect(list.map((c) => c.id), <String>['b', 'a']);
  });

  test('update changes fields; replaces password only when provided', () async {
    await repo.create(_sample('a'), password: 'old');

    await repo.update(_sample('a').copyWith(name: 'Renamed'));
    expect((await repo.getById('a'))!.name, 'Renamed');
    expect(creds.store['a'], 'old');

    await repo.update(_sample('a').copyWith(name: 'Renamed'), password: 'new');
    expect(creds.store['a'], 'new');
  });

  test('delete removes the connection and its secret', () async {
    await repo.create(_sample('a'), password: 'x');

    await repo.delete('a');
    expect(await repo.getById('a'), isNull);
    expect(creds.store.containsKey('a'), isFalse);
  });

  test('duplicate clones metadata and secret under a fresh id', () async {
    await repo.create(_sample('a', name: 'Prod'), password: 'pw');

    final copy = await repo.duplicate('a');
    expect(copy, isNotNull);
    expect(copy!.id, isNot('a'));
    expect(copy.name, 'Prod (copy)');
    expect(creds.store[copy.id], 'pw');
  });

  test('markUsed stamps lastUsedAt', () async {
    await repo.create(_sample('a'), password: 'x');
    expect((await repo.getById('a'))!.lastUsedAt, isNull);

    await repo.markUsed('a');
    expect((await repo.getById('a'))!.lastUsedAt, isNotNull);
  });

  test('enum fields round-trip through persistence', () async {
    await repo.create(
      _sample('a').copyWith(
        sslMode: DbSslMode.verifyFull,
        environment: DbEnvironment.prod,
      ),
      password: 'x',
    );

    final got = (await repo.getById('a'))!;
    expect(got.sslMode, DbSslMode.verifyFull);
    expect(got.environment, DbEnvironment.prod);
    expect(got.isProd, isTrue);
  });
}
