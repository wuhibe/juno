// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_runner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs SQL against the active connection's adapter, applies the pagination
/// rule, supports cancel + "load more", and records each run in history.

@ProviderFor(QueryRunner)
final queryRunnerProvider = QueryRunnerProvider._();

/// Runs SQL against the active connection's adapter, applies the pagination
/// rule, supports cancel + "load more", and records each run in history.
final class QueryRunnerProvider
    extends $NotifierProvider<QueryRunner, QueryRunState> {
  /// Runs SQL against the active connection's adapter, applies the pagination
  /// rule, supports cancel + "load more", and records each run in history.
  QueryRunnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'queryRunnerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$queryRunnerHash();

  @$internal
  @override
  QueryRunner create() => QueryRunner();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QueryRunState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QueryRunState>(value),
    );
  }
}

String _$queryRunnerHash() => r'6de340348d61cadf07ba8df79180445df0d320ce';

/// Runs SQL against the active connection's adapter, applies the pagination
/// rule, supports cancel + "load more", and records each run in history.

abstract class _$QueryRunner extends $Notifier<QueryRunState> {
  QueryRunState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<QueryRunState, QueryRunState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<QueryRunState, QueryRunState>,
              QueryRunState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
