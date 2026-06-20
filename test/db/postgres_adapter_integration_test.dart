// Integration tests for PostgresAdapter against a real PostgreSQL server.
//
// Skipped by default. To run them, start a server and enable the suite:
//
//   docker run --rm -p 5432:5432 -e POSTGRES_PASSWORD=dev postgres:16
//   fvm flutter test --dart-define=JUNO_PG_IT=true \
//       test/db/postgres_adapter_integration_test.dart
//
// Override JUNO_PG_HOST/PORT/DB/USER/PASSWORD as needed.

import 'package:flutter_test/flutter_test.dart';
import 'package:juno/core/errors/app_exception.dart';
import 'package:juno/db/adapter/models/connection_config.dart';
import 'package:juno/db/postgres/postgres_adapter.dart';

const bool _enabled = bool.fromEnvironment('JUNO_PG_IT');
const String _host = String.fromEnvironment(
  'JUNO_PG_HOST',
  defaultValue: 'localhost',
);
const int _port = int.fromEnvironment('JUNO_PG_PORT', defaultValue: 5432);
const String _database = String.fromEnvironment(
  'JUNO_PG_DB',
  defaultValue: 'postgres',
);
const String _user = String.fromEnvironment(
  'JUNO_PG_USER',
  defaultValue: 'postgres',
);
const String _password = String.fromEnvironment(
  'JUNO_PG_PASSWORD',
  defaultValue: 'dev',
);

ConnectionConfig _config({required bool readOnly}) => ConnectionConfig(
  host: _host,
  port: _port,
  database: _database,
  username: _user,
  password: _password,
  sslMode: DbSslMode.disable,
  readOnly: readOnly,
);

void main() {
  group(
    'PostgresAdapter (integration)',
    () {
      late PostgresAdapter adapter;

      setUp(() => adapter = PostgresAdapter());
      tearDown(() => adapter.disconnect());

      test('connects, pings, and runs SELECT 1', () async {
        await adapter.connect(_config(readOnly: true));
        expect(adapter.isConnected, isTrue);

        final latency = await adapter.ping();
        expect(latency, isA<Duration>());

        final result = await adapter.execute('SELECT 1 AS one');
        expect(result.rowCount, 1);
        expect(result.columns.single.name, 'one');
        expect(result.rows.single.single, 1);
      });

      test('read-only connection rejects writes server-side', () async {
        await adapter.connect(_config(readOnly: true));
        await expectLater(
          adapter.execute('CREATE TABLE juno_should_not_exist (id int)'),
          throwsA(isA<ReadOnlyViolationException>()),
        );
      });

      test(
        'a CTE-wrapped write is also rejected on a read-only connection',
        () async {
          await adapter.connect(_config(readOnly: true));
          await expectLater(
            adapter.execute(
              'WITH x AS (CREATE TABLE juno_cte (id int) RETURNING *) '
              'SELECT * FROM x',
            ),
            throwsA(isA<AppException>()),
          );
        },
      );

      test('introspects schemas, tables, and columns', () async {
        await adapter.connect(_config(readOnly: true));

        final userSchemas = await adapter.listSchemas();
        expect(userSchemas.every((s) => !s.isSystem), isTrue);

        final allSchemas = await adapter.listSchemas(includeSystem: true);
        expect(allSchemas.map((s) => s.name), contains('pg_catalog'));

        final tables = await adapter.listTables('pg_catalog');
        expect(tables.map((t) => t.name), contains('pg_class'));

        final columns = await adapter.listColumns('pg_catalog', 'pg_class');
        expect(columns, isNotEmpty);
        expect(columns.map((c) => c.name), contains('relname'));
      });
    },
    skip: _enabled
        ? false
        : 'Set --dart-define=JUNO_PG_IT=true with a reachable Postgres to run.',
  );
}
