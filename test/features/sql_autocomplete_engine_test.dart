import 'package:flutter_test/flutter_test.dart';
import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:juno/features/editor/domain/sql_autocomplete_engine.dart';
import 'package:juno/features/editor/domain/sql_schema_snapshot.dart';
import 'package:juno/features/editor/domain/sql_suggestion.dart';

DbColumn _col(String name, {String type = 'text'}) => DbColumn(
  name: name,
  dataType: type,
  isNullable: true,
  isPrimaryKey: false,
  ordinalPosition: 1,
);

final _snapshot = SqlSchemaSnapshot(
  tables: const <DbTable>[
    DbTable(schema: 'public', name: 'users', kind: DbObjectKind.table),
    DbTable(schema: 'public', name: 'usage_events', kind: DbObjectKind.table),
    DbTable(schema: 'public', name: 'orders', kind: DbObjectKind.table),
  ],
  columnsByTable: <String, List<DbColumn>>{
    'users': <DbColumn>[_col('id', type: 'int4'), _col('name'), _col('email')],
    'orders': <DbColumn>[
      _col('id', type: 'int4'),
      _col('user_id', type: 'int4'),
    ],
  },
);

/// Suggestions for the cursor at the end of [line].
List<SqlSuggestion> _suggest(String line) =>
    SqlAutocompleteEngine(_snapshot).suggest(line, line.length);

List<String> _labels(String line) =>
    _suggest(line).map((s) => s.label).toList();

void main() {
  group('SqlAutocompleteEngine — acceptance', () {
    test('after FROM, a table prefix offers matching tables', () {
      final labels = _labels('SELECT * FROM us');
      expect(labels, contains('users'));
      expect(labels, contains('usage_events'));
      expect(labels, isNot(contains('orders')));
      expect(
        _suggest(
          'SELECT * FROM us',
        ).every((s) => s.kind == SqlSuggestionKind.table),
        isTrue,
      );
    });

    test('after FROM with no prefix, all tables are offered', () {
      expect(
        _labels('SELECT * FROM '),
        containsAll(<String>['users', 'orders']),
      );
    });

    test(
      'column suggestions appear in the SELECT list once FROM is present',
      () {
        // Cursor sits in the SELECT list, before the FROM clause.
        const line = 'SELECT  FROM users';
        const cursor = 7; // right after "SELECT "
        final suggestions = SqlAutocompleteEngine(
          _snapshot,
        ).suggest(line, cursor);
        final columns = suggestions
            .where((s) => s.kind == SqlSuggestionKind.column)
            .map((s) => s.label);
        expect(columns, containsAll(<String>['id', 'name', 'email']));
      },
    );

    test('column suggestions appear in the WHERE clause', () {
      final labels = _labels('SELECT * FROM users WHERE na');
      expect(labels, contains('name'));
      expect(labels, isNot(contains('email')));
    });
  });

  group('SqlAutocompleteEngine — context', () {
    test('alias-qualified access offers only that table\'s columns', () {
      final labels = _labels('SELECT * FROM orders o WHERE o.user_');
      expect(labels, <String>['user_id']);
    });

    test('a bare table name qualifier resolves columns', () {
      // Cursor sits right after "SELECT users." (offset 13).
      const line = 'SELECT users. FROM users';
      final suggestions = SqlAutocompleteEngine(_snapshot).suggest(line, 13);
      final labels = suggestions.map((s) => s.label);
      expect(labels, containsAll(<String>['id', 'name', 'email']));
    });

    test('an empty buffer offers nothing (no keyword dump)', () {
      expect(_suggest(''), isEmpty);
      expect(_suggest('   '), isEmpty);
    });

    test('a keyword prefix at statement start is completed', () {
      expect(_labels('SEL'), contains('SELECT'));
    });

    test('keywords are still offered alongside columns in a column clause', () {
      final labels = _labels('SELECT * FROM users WHERE name = 1 OR');
      expect(labels, contains('ORDER'));
      expect(labels, contains('OR'));
    });

    test('comments do not derail clause detection', () {
      final labels = _labels('SELECT * FROM users -- WHERE x\n  WHERE em');
      expect(labels, contains('email'));
    });
  });
}
