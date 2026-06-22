import 'package:juno/db/adapter/models/schema_objects.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_editor_table_provider.g.dart';

/// The table the snippet toolbar currently offers column chips for.
///
/// Set when the user picks a table from the `FROM` quick-pick sheet or taps a
/// table chip; cleared when the connection changes (the provider is rebuilt).
@riverpod
class ActiveEditorTable extends _$ActiveEditorTable {
  @override
  DbTable? build() => null;

  /// Marks [table] as the active table for column suggestions.
  void select(DbTable table) => state = table;

  /// Clears the active table.
  void clear() => state = null;
}
