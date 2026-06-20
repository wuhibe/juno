import 'package:flutter_test/flutter_test.dart';
import 'package:juno/features/editor/domain/sql_statement.dart';

void main() {
  group('SqlStatement.classify', () {
    test('a bare SELECT is paginable', () {
      final s = SqlStatement.classify('SELECT * FROM users');
      expect(s.kind, StatementKind.select);
      expect(s.hasLimit, isFalse);
      expect(s.isPaginable, isTrue);
    });

    test('a SELECT with its own LIMIT is not paginable', () {
      final s = SqlStatement.classify('select * from t LIMIT 10');
      expect(s.hasLimit, isTrue);
      expect(s.isPaginable, isFalse);
    });

    test('INSERT/UPDATE/DELETE are writes and never paginable', () {
      expect(
        SqlStatement.classify('INSERT INTO t VALUES (1)').kind,
        StatementKind.write,
      );
      expect(
        SqlStatement.classify('UPDATE t SET x = 1').kind,
        StatementKind.write,
      );
      expect(SqlStatement.classify('DELETE FROM t').isPaginable, isFalse);
    });

    test('a CTE-wrapped write is classified as a write', () {
      final s = SqlStatement.classify(
        'WITH x AS (DELETE FROM t RETURNING *) SELECT * FROM x',
      );
      expect(s.kind, StatementKind.write);
      expect(s.isPaginable, isFalse);
    });

    test('a read-only CTE is a select but not auto-paginated', () {
      final s = SqlStatement.classify('WITH x AS (SELECT 1) SELECT * FROM x');
      expect(s.kind, StatementKind.select);
      // Only statements starting with SELECT are auto-paginated.
      expect(s.isPaginable, isFalse);
    });

    test('CREATE is DDL', () {
      expect(
        SqlStatement.classify('CREATE TABLE t (id int)').kind,
        StatementKind.ddl,
      );
    });

    test('keywords inside comments are ignored', () {
      final s = SqlStatement.classify('-- limit 5\nSELECT * FROM t');
      expect(s.hasLimit, isFalse);
      expect(s.isPaginable, isTrue);
    });

    test('keywords inside string literals are ignored', () {
      final s = SqlStatement.classify("SELECT 'limit 5' FROM t");
      expect(s.hasLimit, isFalse);
      expect(s.firstKeyword, 'select');
    });

    test('normalized strips trailing semicolons', () {
      expect(SqlStatement.classify('SELECT 1;').normalized, 'SELECT 1');
      expect(SqlStatement.classify('SELECT 1 ;  ').normalized, 'SELECT 1');
    });

    test('empty input is classified as other', () {
      final s = SqlStatement.classify('   ');
      expect(s.firstKeyword, '');
      expect(s.kind, StatementKind.other);
    });
  });
}
