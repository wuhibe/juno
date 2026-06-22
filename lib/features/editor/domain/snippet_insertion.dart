import 'package:juno/features/editor/domain/snippet_chip.dart';

/// The result of planning a snippet insertion: the exact [text] to splice in at
/// the cursor and where the cursor should end up afterwards.
class SnippetInsertion {
  /// Creates an insertion plan.
  const SnippetInsertion({required this.text, required this.cursorOffset});

  /// The text to insert (already padded with any smart leading/trailing space).
  final String text;

  /// Cursor offset measured from the *start* of [text] once inserted.
  final int cursorOffset;
}

/// Plans how to splice a snippet into the editor with smart spacing — auto-space
/// before/after keywords, hug punctuation, and drop the cursor inside trailing
/// pairs like `()` and `''` (plan §8).
abstract final class SnippetInserter {
  /// Plans inserting [chip] between [before] (text left of the cursor on the
  /// line) and [after] (text right of it).
  static SnippetInsertion plan({
    required String before,
    required String after,
    required SnippetChip chip,
  }) {
    final insert = chip.insertText;
    final first = insert.isEmpty ? '' : insert[0];
    final last = insert.isEmpty ? '' : insert[insert.length - 1];

    final leading = _needsLeadingSpace(before, first) ? ' ' : '';
    final landsInside = chip.cursorBack > 0;
    final trailing = !landsInside && _needsTrailingSpace(after, last)
        ? ' '
        : '';

    final text = '$leading$insert$trailing';
    final cursorOffset = landsInside
        ? leading.length + insert.length - chip.cursorBack
        : leading.length + insert.length + trailing.length;

    return SnippetInsertion(text: text, cursorOffset: cursorOffset);
  }

  /// A space is needed before the snippet unless we're at the line start, the
  /// previous char is already whitespace or an open paren, or the snippet
  /// itself hugs the previous token (closing punctuation).
  static bool _needsLeadingSpace(String before, String first) {
    if (before.isEmpty) {
      return false;
    }
    final prev = before[before.length - 1];
    if (prev == ' ' || prev == '\t' || prev == '\n' || prev == '(') {
      return false;
    }
    if (first == ')' || first == ',' || first == ';') {
      return false;
    }
    return true;
  }

  /// A trailing space keeps chips composable after words/operators, but not when
  /// the next char is already whitespace or the snippet ends on an opening pair.
  static bool _needsTrailingSpace(String after, String last) {
    if (last == '(' || last == "'" || last == ';') {
      return false;
    }
    if (after.isNotEmpty) {
      final nextCh = after[0];
      if (nextCh == ' ' || nextCh == '\n' || nextCh == '\t') {
        return false;
      }
    }
    return true;
  }
}
