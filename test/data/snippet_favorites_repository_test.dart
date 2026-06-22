import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juno/data/app_database.dart';
import 'package:juno/data/snippet_favorites_repository.dart';

void main() {
  late AppDatabase db;
  late SnippetFavoritesRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SnippetFavoritesRepository(db);
  });

  tearDown(() => db.close());

  test('pinning adds labels in insertion order', () async {
    await repo.pin('SELECT');
    await repo.pin('WHERE');
    await repo.pin('FROM');

    expect(await repo.watchAll().first, <String>['SELECT', 'WHERE', 'FROM']);
  });

  test('pinning the same label twice is a no-op', () async {
    await repo.pin('SELECT');
    await repo.pin('SELECT');

    expect(await repo.watchAll().first, <String>['SELECT']);
  });

  test('unpinning removes a label', () async {
    await repo.pin('SELECT');
    await repo.pin('WHERE');
    await repo.unpin('SELECT');

    expect(await repo.watchAll().first, <String>['WHERE']);
  });
}
