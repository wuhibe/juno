import 'package:flutter_test/flutter_test.dart';
import 'package:juno/features/editor/domain/sql_tokenizer.dart';

void main() {
  group('SqlTokenizer.tokenize', () {
    test('yields words with their source positions', () {
      final tokens = SqlTokenizer.tokenize('SELECT id FROM users');
      expect(tokens.map((t) => t.text), <String>[
        'SELECT',
        'id',
        'FROM',
        'users',
      ]);
      expect(tokens.first.start, 0);
      expect(tokens.first.end, 6);
      // 'users' starts at offset 15.
      expect(tokens.last.start, 15);
      expect(tokens.last.end, 20);
    });

    test('skips line and block comments', () {
      final tokens = SqlTokenizer.tokenize(
        '-- drop everything\nSELECT 1 /* delete */ FROM t',
      );
      expect(tokens.map((t) => t.lower), <String>['select', 'from', 't']);
    });

    test('skips string and identifier literals', () {
      final tokens = SqlTokenizer.tokenize(
        'SELECT \'from inside\' AS "delete me" FROM t',
      );
      expect(tokens.map((t) => t.lower), <String>['select', 'as', 'from', 't']);
    });

    test('skips dollar-quoted blocks', () {
      final tokens = SqlTokenizer.tokenize(
        r'SELECT $$ DELETE FROM x $$ FROM t',
      );
      expect(tokens.map((t) => t.lower), <String>['select', 'from', 't']);
    });

    test('flags a word immediately preceded by a dot', () {
      final tokens = SqlTokenizer.tokenize('SELECT u.name FROM users u');
      final name = tokens.firstWhere((t) => t.text == 'name');
      expect(name.precededByDot, isTrue);
      final u = tokens.firstWhere((t) => t.text == 'u');
      expect(u.precededByDot, isFalse);
    });

    test('handles an empty string escape inside a literal', () {
      final tokens = SqlTokenizer.tokenize("SELECT 'it''s' FROM t");
      expect(tokens.map((t) => t.lower), <String>['select', 'from', 't']);
    });
  });
}
