import 'package:flutter_test/flutter_test.dart';
import 'package:juno/features/editor/domain/snippet_catalog.dart';
import 'package:juno/features/editor/domain/snippet_chip.dart';
import 'package:juno/features/editor/domain/snippet_insertion.dart';

SnippetChip _chip(
  String text, {
  int cursorBack = 0,
  SnippetCategory category = SnippetCategory.structure,
}) => SnippetChip(
  label: text,
  insertText: text,
  category: category,
  cursorBack: cursorBack,
);

void main() {
  group('SnippetInserter.plan — spacing', () {
    test('a keyword in an empty buffer gets only a trailing space', () {
      final plan = SnippetInserter.plan(
        before: '',
        after: '',
        chip: _chip('SELECT'),
      );
      expect(plan.text, 'SELECT ');
      expect(plan.cursorOffset, 'SELECT '.length);
    });

    test('a keyword after a word gets a leading and trailing space', () {
      final plan = SnippetInserter.plan(
        before: 'SELECT',
        after: '',
        chip: _chip('FROM'),
      );
      expect(plan.text, ' FROM ');
      expect(plan.cursorOffset, ' FROM '.length);
    });

    test('no leading space when the previous char is already a space', () {
      final plan = SnippetInserter.plan(
        before: 'SELECT ',
        after: '',
        chip: _chip('FROM'),
      );
      expect(plan.text, 'FROM ');
    });

    test('no trailing space when the next char is already a space', () {
      final plan = SnippetInserter.plan(
        before: 'SELECT ',
        after: ' FROM x',
        chip: _chip('*', category: SnippetCategory.value),
      );
      expect(plan.text, '*');
    });

    test('punctuation hugs the previous token', () {
      final plan = SnippetInserter.plan(
        before: 'a',
        after: '',
        chip: _chip(',', category: SnippetCategory.value),
      );
      expect(plan.text, ', ');
      expect(plan.cursorOffset, 2);
    });
  });

  group('SnippetInserter.plan — cursor placement', () {
    test('a trailing pair drops the cursor inside', () {
      final plan = SnippetInserter.plan(
        before: 'x',
        after: '',
        chip: _chip('()', cursorBack: 1, category: SnippetCategory.value),
      );
      expect(plan.text, ' ()');
      // ' ()' → cursor between the parens (offset 2).
      expect(plan.cursorOffset, 2);
    });

    test("the LIKE '%…%' variant lands the cursor between the percents", () {
      final like = SnippetCatalog.operators
          .firstWhere((c) => c.label == 'LIKE')
          .variants
          .firstWhere((v) => v.cursorBack == 2);
      final plan = SnippetInserter.plan(before: 'name', after: '', chip: like);
      expect(plan.text, " LIKE '%%'");
      // Between the two % signs.
      expect(plan.text[plan.cursorOffset - 1], '%');
      expect(plan.text[plan.cursorOffset], '%');
    });
  });
}
