/// The category of an autocomplete suggestion — mirrors the snippet/semantic
/// palette so the dropdown reads like the rest of the editor (keywords violet,
/// schema identifiers green).
enum SqlSuggestionKind {
  /// A SQL keyword (`SELECT`, `FROM`, `WHERE`, …).
  keyword,

  /// A table, view, or materialized view name from the schema cache.
  table,

  /// A column name from the schema cache.
  column,
}

/// One ranked autocomplete entry surfaced to the editor.
class SqlSuggestion {
  /// Creates a suggestion.
  const SqlSuggestion({
    required this.label,
    required this.insertText,
    required this.kind,
    this.detail,
  });

  /// The text shown in the dropdown.
  final String label;

  /// The text actually inserted when chosen (often equal to [label]).
  final String insertText;

  /// Which palette/category this suggestion belongs to.
  final SqlSuggestionKind kind;

  /// Optional trailing context (a column's type, a table's schema).
  final String? detail;

  @override
  bool operator ==(Object other) =>
      other is SqlSuggestion &&
      other.label == label &&
      other.insertText == insertText &&
      other.kind == kind &&
      other.detail == detail;

  @override
  int get hashCode => Object.hash(label, insertText, kind, detail);

  @override
  String toString() => 'SqlSuggestion($label, $kind)';
}
