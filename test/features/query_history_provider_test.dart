import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juno/data/data_providers.dart';
import 'package:juno/data/models/query_history_entry.dart';
import 'package:juno/data/query_history_repository.dart';
import 'package:juno/features/history/application/query_history_provider.dart';

/// A canned history repo: only [watchForConnection] is exercised here.
class _FakeHistoryRepo implements QueryHistoryRepository {
  @override
  Stream<List<QueryHistoryEntry>> watchForConnection(String connectionId) {
    return Stream<List<QueryHistoryEntry>>.value(<QueryHistoryEntry>[
      QueryHistoryEntry(
        connectionId: connectionId,
        sqlText: 'SELECT 1',
        startedAt: DateTime(2026, 1, 1),
        elapsedMs: 3,
        success: true,
        rowCount: 1,
      ),
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'queryHistory forwards the repository stream for a connection',
    () async {
      final container = ProviderContainer(
        overrides: [
          queryHistoryRepositoryProvider.overrideWithValue(_FakeHistoryRepo()),
        ],
      );
      addTearDown(container.dispose);

      // Keep the auto-dispose provider alive while awaiting its first value.
      container.listen(
        queryHistoryProvider('conn-1'),
        (_, _) {},
        fireImmediately: true,
      );

      final entries = await container.read(
        queryHistoryProvider('conn-1').future,
      );
      expect(entries, hasLength(1));
      expect(entries.single.connectionId, 'conn-1');
      expect(entries.single.sqlText, 'SELECT 1');
    },
  );
}
