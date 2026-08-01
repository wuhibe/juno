/// The colour-coded block category a [SnippetChip] belongs to.
enum SnippetCategory {
  /// Statement structure — violet (`SELECT`, `FROM`, `WHERE`, `JOIN`, …).
  structure,

  /// Operators — amber (`=`, `LIKE`, `AND`, `IS NULL`, …).
  operators,

  /// Values & punctuation — teal (`''`, `()`, `*`, `NULL`, `COUNT(*)`, …).
  value,

  /// Dynamic schema chips — green (tables, columns, aliases).
  smart,
}

/// A single tappable snippet that inserts text at the cursor with smart spacing.
///
/// [cursorBack] is how many characters from the end of [insertText] the cursor
/// should land — `0` leaves it at the end (e.g. after a keyword), `1` drops it
/// inside a trailing pair such as `()` or `''`.
class SnippetChip {
  /// Creates a chip.
  const SnippetChip({
    required this.label,
    required this.insertText,
    required this.category,
    this.cursorBack = 0,
    this.isWrite = false,
    this.variants = const <SnippetChip>[],
  });

  /// The text shown on the chip.
  final String label;

  /// The raw text inserted (before smart leading/trailing spacing is applied).
  final String insertText;

  /// Which palette/category this chip belongs to.
  final SnippetCategory category;

  /// Characters from the end of [insertText] to place the cursor.
  final int cursorBack;

  /// Whether this is a write/DDL chip — hidden on read-only connections (§8 ¹).
  final bool isWrite;

  /// Long-press variants (e.g. `JOIN` → LEFT/RIGHT/INNER/FULL). Empty when the
  /// chip has no menu. The chip itself is conventionally the first entry the
  /// menu surfaces, so callers usually prepend `this`.
  final List<SnippetChip> variants;

  /// Whether a long-press variant menu should be offered.
  bool get hasVariants => variants.isNotEmpty;
}
