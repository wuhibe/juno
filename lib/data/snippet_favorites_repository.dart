import 'package:drift/drift.dart';
import 'package:juno/data/app_database.dart';

/// Stores the snippet chips the user has pinned to the editor toolbar's
/// favorites group (plan §8). Labels only — no schema or secret data.
class SnippetFavoritesRepository {
  /// Creates the repository over [_db].
  SnippetFavoritesRepository(this._db);

  final AppDatabase _db;

  /// Watches the pinned chip labels, in pin order then alphabetical.
  Stream<List<String>> watchAll() {
    final query = _db.select(_db.snippetFavorites)
      ..orderBy(<OrderClauseGenerator<$SnippetFavoritesTable>>[
        (t) => OrderingTerm(expression: t.sortOrder),
        (t) => OrderingTerm(expression: t.label),
      ]);
    return query.watch().map(
      (rows) => rows.map((row) => row.label).toList(growable: false),
    );
  }

  /// Pins [label] (appended after existing favorites). No-op if already pinned.
  Future<void> pin(String label) async {
    final count = await _db.snippetFavorites.count().getSingle();
    await _db
        .into(_db.snippetFavorites)
        .insert(
          SnippetFavoritesCompanion.insert(
            label: label,
            sortOrder: Value(count),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  /// Unpins [label].
  Future<void> unpin(String label) {
    return (_db.delete(
      _db.snippetFavorites,
    )..where((t) => t.label.equals(label))).go();
  }
}
