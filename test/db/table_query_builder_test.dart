import 'package:flutter_test/flutter_test.dart';
import 'package:juno/db/adapter/models/table_query.dart';
import 'package:juno/db/postgres/postgres_adapter.dart';

void main() {
  late PostgresAdapter adapter;

  setUp(() => adapter = PostgresAdapter());

  ({String sql, Map<String, Object?> params}) build({
    List<ColumnFilter> filters = const <ColumnFilter>[],
    ColumnSort? sort,
    int limit = 200,
    int offset = 0,
  }) => adapter.buildTableQuery(
    schema: 'public',
    table: 'users',
    filters: filters,
    sort: sort,
    limit: limit,
    offset: offset,
  );

  group('buildTableQuery', () {
    test('unfiltered query is a plain paged select', () {
      final query = build();
      expect(query.sql, 'SELECT * FROM "public"."users" LIMIT 200');
      expect(query.params, isEmpty);
    });

    test('offset is included only when paging past the first page', () {
      expect(build(offset: 400).sql, endsWith('LIMIT 200 OFFSET 400'));
    });

    test('quotes identifiers containing a double quote', () {
      final query = adapter.buildTableQuery(
        schema: 'we"ird',
        table: 'ta"ble',
        limit: 10,
        sort: const ColumnSort(column: 'co"l', direction: SortDirection.asc),
      );
      expect(
        query.sql,
        'SELECT * FROM "we""ird"."ta""ble" ORDER BY "co""l" ASC LIMIT 10',
      );
    });

    test('binds comparison values instead of interpolating them', () {
      final query = build(
        filters: <ColumnFilter>[
          const ColumnFilter(
            column: 'age',
            op: FilterOperator.gte,
            values: <String>['18'],
          ),
        ],
      );
      expect(query.sql, contains('WHERE "age" >= @f0'));
      expect(query.params, <String, Object?>{'f0': '18'});
    });

    test('a value carrying SQL never reaches the statement', () {
      final query = build(
        filters: <ColumnFilter>[
          const ColumnFilter(
            column: 'name',
            op: FilterOperator.eq,
            values: <String>["x'; DROP TABLE users; --"],
          ),
        ],
      );
      expect(query.sql, isNot(contains('DROP')));
      expect(query.params['f0'], "x'; DROP TABLE users; --");
    });

    test('AND-joins multiple filters with distinct parameter names', () {
      final query = build(
        filters: <ColumnFilter>[
          const ColumnFilter(
            column: 'age',
            op: FilterOperator.gt,
            values: <String>['18'],
          ),
          const ColumnFilter(
            column: 'city',
            op: FilterOperator.eq,
            values: <String>['Addis'],
          ),
        ],
      );
      expect(query.sql, contains('WHERE "age" > @f0 AND "city" = @f1'));
      expect(query.params, <String, Object?>{'f0': '18', 'f1': 'Addis'});
    });

    test('contains and startsWith cast to text and escape wildcards', () {
      final substringMatch = build(
        filters: <ColumnFilter>[
          const ColumnFilter(
            column: 'mood',
            op: FilterOperator.contains,
            values: <String>['50%_off'],
          ),
        ],
      );
      expect(substringMatch.sql, contains('"mood"::text ILIKE @f0'));
      expect(substringMatch.params['f0'], r'%50\%\_off%');

      final prefix = build(
        filters: <ColumnFilter>[
          const ColumnFilter(
            column: 'name',
            op: FilterOperator.startsWith,
            values: <String>['a'],
          ),
        ],
      );
      expect(prefix.params['f0'], 'a%');
    });

    test('inList expands to ORed equalities, not an array parameter', () {
      final query = build(
        filters: <ColumnFilter>[
          const ColumnFilter(
            column: 'mood',
            op: FilterOperator.inList,
            values: <String>['sad', 'happy'],
          ),
        ],
      );
      expect(query.sql, contains('("mood" = @f0_0 OR "mood" = @f0_1)'));
      expect(query.sql, isNot(contains('ANY')));
      expect(query.params, <String, Object?>{'f0_0': 'sad', 'f0_1': 'happy'});
    });

    test('null checks bind nothing', () {
      final query = build(
        filters: <ColumnFilter>[
          const ColumnFilter(column: 'deleted_at', op: FilterOperator.isNull),
          const ColumnFilter(column: 'email', op: FilterOperator.isNotNull),
        ],
      );
      expect(
        query.sql,
        contains('WHERE "deleted_at" IS NULL AND "email" IS NOT NULL'),
      );
      expect(query.params, isEmpty);
    });

    test('sorts descending after the WHERE clause', () {
      final query = build(
        filters: <ColumnFilter>[
          const ColumnFilter(
            column: 'city',
            op: FilterOperator.eq,
            values: <String>['Addis'],
          ),
        ],
        sort: const ColumnSort(
          column: 'created_at',
          direction: SortDirection.desc,
        ),
      );
      expect(
        query.sql,
        'SELECT * FROM "public"."users" WHERE "city" = @f0 '
        'ORDER BY "created_at" DESC LIMIT 200',
      );
    });

    test('rejects a filter that is missing its value', () {
      expect(
        () => build(
          filters: <ColumnFilter>[
            const ColumnFilter(column: 'age', op: FilterOperator.eq),
          ],
        ),
        throwsArgumentError,
      );
    });
  });
}
