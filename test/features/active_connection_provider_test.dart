import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juno/data/app_database.dart';
import 'package:juno/data/data_providers.dart';
import 'package:juno/data/secure_credentials_repository.dart';
import 'package:juno/features/connections/application/active_connection_provider.dart';

class _InMemoryCredentials implements SecureCredentialsRepository {
  @override
  Future<void> savePassword(String connectionId, String password) async {}

  @override
  Future<String?> readPassword(String connectionId) async => null;

  @override
  Future<void> deletePassword(String connectionId) async {}
}

void main() {
  test('starts idle', () {
    final container = _container();
    addTearDown(container.dispose);
    expect(container.read(activeConnectionProvider), isA<ConnectionIdle>());
  });

  test(
    'connecting to an unknown connection ends in ConnectionFailed',
    () async {
      final container = _container();
      addTearDown(container.dispose);

      await container
          .read(activeConnectionProvider.notifier)
          .connect('does-not-exist');

      expect(container.read(activeConnectionProvider), isA<ConnectionFailed>());
    },
  );
}

ProviderContainer _container() {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWith((ref) => db),
      secureCredentialsRepositoryProvider.overrideWith(
        (ref) => _InMemoryCredentials(),
      ),
    ],
  );
}
