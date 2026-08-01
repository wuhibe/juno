// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Live query history for [connectionId], newest first.

@ProviderFor(queryHistory)
final queryHistoryProvider = QueryHistoryFamily._();

/// Live query history for [connectionId], newest first.

final class QueryHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<QueryHistoryEntry>>,
          List<QueryHistoryEntry>,
          Stream<List<QueryHistoryEntry>>
        >
    with
        $FutureModifier<List<QueryHistoryEntry>>,
        $StreamProvider<List<QueryHistoryEntry>> {
  /// Live query history for [connectionId], newest first.
  QueryHistoryProvider._({
    required QueryHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'queryHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$queryHistoryHash();

  @override
  String toString() {
    return r'queryHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<QueryHistoryEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<QueryHistoryEntry>> create(Ref ref) {
    final argument = this.argument as String;
    return queryHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is QueryHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$queryHistoryHash() => r'39c794ad46793183a4199fb82e545ec9f60e7d4e';

/// Live query history for [connectionId], newest first.

final class QueryHistoryFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<QueryHistoryEntry>>, String> {
  QueryHistoryFamily._()
    : super(
        retry: null,
        name: r'queryHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live query history for [connectionId], newest first.

  QueryHistoryProvider call(String connectionId) =>
      QueryHistoryProvider._(argument: connectionId, from: this);

  @override
  String toString() => r'queryHistoryProvider';
}
