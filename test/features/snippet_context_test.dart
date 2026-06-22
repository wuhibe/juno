import 'package:flutter_test/flutter_test.dart';
import 'package:juno/features/editor/domain/snippet_context.dart';

void main() {
  group('SnippetContext.analyze', () {
    test('empty buffer or after a semicolon is statement start', () {
      expect(SnippetContext.analyze(''), EditorContext.statementStart);
      expect(SnippetContext.analyze('SELECT 1;'), EditorContext.statementStart);
    });

    test('right after SELECT', () {
      expect(SnippetContext.analyze('SELECT '), EditorContext.afterSelect);
    });

    test('right after FROM / JOIN', () {
      expect(SnippetContext.analyze('SELECT * FROM '), EditorContext.afterFrom);
      expect(
        SnippetContext.analyze('SELECT * FROM a JOIN '),
        EditorContext.afterFrom,
      );
    });

    test('inside a WHERE predicate', () {
      expect(
        SnippetContext.analyze('SELECT * FROM users WHERE '),
        EditorContext.afterWhere,
      );
    });

    test('after a bare comparison operator', () {
      expect(
        SnippetContext.analyze('SELECT * FROM users WHERE id = '),
        EditorContext.afterOperator,
      );
    });

    test('after a keyword operator like LIKE', () {
      expect(
        SnippetContext.analyze('SELECT * FROM users WHERE name LIKE '),
        EditorContext.afterOperator,
      );
    });

    test('after ORDER BY', () {
      expect(
        SnippetContext.analyze('SELECT * FROM users ORDER BY '),
        EditorContext.afterOrderBy,
      );
    });

    test('a trailing table/identifier reference', () {
      expect(
        SnippetContext.analyze('SELECT * FROM users'),
        EditorContext.afterTable,
      );
    });
  });

  group('SnippetContext.orderGroups', () {
    test('FROM leads with table chips', () {
      expect(
        SnippetContext.orderGroups(EditorContext.afterFrom).first,
        SnippetGroup.tables,
      );
    });

    test('SELECT and WHERE lead with column chips', () {
      expect(
        SnippetContext.orderGroups(EditorContext.afterSelect).first,
        SnippetGroup.columns,
      );
      expect(
        SnippetContext.orderGroups(EditorContext.afterWhere).first,
        SnippetGroup.columns,
      );
    });

    test('statement start leads with structure chips', () {
      expect(
        SnippetContext.orderGroups(EditorContext.statementStart).first,
        SnippetGroup.structure,
      );
    });

    test('every ordering covers all five groups', () {
      for (final context in EditorContext.values) {
        expect(SnippetContext.orderGroups(context).toSet(), hasLength(5));
      }
    });
  });
}
