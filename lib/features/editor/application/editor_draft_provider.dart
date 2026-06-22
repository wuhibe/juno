import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'editor_draft_provider.g.dart';

/// A request to load SQL into the editor from elsewhere (e.g. the history
/// screen's "insert into editor" / "re-run").
class EditorDraft {
  /// Creates a draft for [sql], optionally auto-running it.
  const EditorDraft({required this.sql, required this.run});

  /// The SQL to place in the editor.
  final String sql;

  /// Whether the editor should immediately run [sql] after loading it.
  final bool run;
}

/// A one-shot channel that hands SQL to the editor from another screen.
///
/// The history screen sets a draft and pops back to the (still-mounted) editor,
/// which consumes it via a listener and clears it.
@riverpod
class EditorDraftRequest extends _$EditorDraftRequest {
  @override
  EditorDraft? build() => null;

  /// Loads [sql] into the editor; pass [run] to also execute it.
  void load(String sql, {bool run = false}) =>
      state = EditorDraft(sql: sql, run: run);

  /// Clears a consumed draft.
  void clear() => state = null;
}
