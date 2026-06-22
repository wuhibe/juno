import 'package:juno/data/data_providers.dart';
import 'package:juno/data/models/query_history_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'query_history_provider.g.dart';

/// Live query history for [connectionId], newest first (plan §8.1).
@riverpod
Stream<List<QueryHistoryEntry>> queryHistory(Ref ref, String connectionId) =>
    ref.watch(queryHistoryRepositoryProvider).watchForConnection(connectionId);
