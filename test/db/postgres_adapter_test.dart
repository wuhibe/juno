import 'package:flutter_test/flutter_test.dart';
import 'package:juno/db/adapter/adapter_registry.dart';
import 'package:juno/db/adapter/models/connection_config.dart';
import 'package:juno/db/postgres/postgres_adapter.dart';

void main() {
  late PostgresAdapter adapter;

  setUp(() => adapter = PostgresAdapter());

  test('reports the postgres kind and starts disconnected', () {
    expect(adapter.kind, DatabaseKind.postgres);
    expect(adapter.isConnected, isFalse);
  });

  test('quoteIdentifier double-quotes and escapes embedded quotes', () {
    expect(adapter.quoteIdentifier('users'), '"users"');
    expect(adapter.quoteIdentifier('weird"name'), '"weird""name"');
  });

  test('limitClause omits OFFSET when it is zero', () {
    expect(adapter.limitClause(100, 0), 'LIMIT 100');
    expect(adapter.limitClause(200, 400), 'LIMIT 200 OFFSET 400');
  });

  test('querying before connect throws a StateError', () {
    expectLater(adapter.execute('SELECT 1'), throwsA(isA<StateError>()));
  });

  test('disconnect is safe to call when never connected', () {
    expect(adapter.disconnect(), completes);
  });

  group('AdapterRegistry', () {
    test('builds a PostgresAdapter for the postgres kind', () {
      expect(
        AdapterRegistry.create(DatabaseKind.postgres),
        isA<PostgresAdapter>(),
      );
      expect(AdapterRegistry.supports(DatabaseKind.postgres), isTrue);
    });
  });
}
