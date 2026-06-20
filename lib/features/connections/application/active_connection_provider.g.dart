// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_connection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the single active database connection and its adapter.
///
/// Holds the adapter lifecycle so the rest of the app talks to a live
/// connection through [ConnectionConnected.adapter] without ever creating or
/// disposing adapters itself.

@ProviderFor(ActiveConnection)
final activeConnectionProvider = ActiveConnectionProvider._();

/// Owns the single active database connection and its adapter.
///
/// Holds the adapter lifecycle so the rest of the app talks to a live
/// connection through [ConnectionConnected.adapter] without ever creating or
/// disposing adapters itself.
final class ActiveConnectionProvider
    extends $NotifierProvider<ActiveConnection, ConnectionStatus> {
  /// Owns the single active database connection and its adapter.
  ///
  /// Holds the adapter lifecycle so the rest of the app talks to a live
  /// connection through [ConnectionConnected.adapter] without ever creating or
  /// disposing adapters itself.
  ActiveConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeConnectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeConnectionHash();

  @$internal
  @override
  ActiveConnection create() => ActiveConnection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionStatus>(value),
    );
  }
}

String _$activeConnectionHash() => r'c79b79c3abc725b1e084a4d3320dfcda0f930075';

/// Owns the single active database connection and its adapter.
///
/// Holds the adapter lifecycle so the rest of the app talks to a live
/// connection through [ConnectionConnected.adapter] without ever creating or
/// disposing adapters itself.

abstract class _$ActiveConnection extends $Notifier<ConnectionStatus> {
  ConnectionStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ConnectionStatus, ConnectionStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConnectionStatus, ConnectionStatus>,
              ConnectionStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The live adapter for the active connection.
///
/// Throws [StateError] when no connection is open, so dependent providers
/// surface a clean error state rather than silently doing nothing. Recomputes
/// whenever the connection changes, which transitively invalidates the schema
/// cache and any running queries.

@ProviderFor(activeAdapter)
final activeAdapterProvider = ActiveAdapterProvider._();

/// The live adapter for the active connection.
///
/// Throws [StateError] when no connection is open, so dependent providers
/// surface a clean error state rather than silently doing nothing. Recomputes
/// whenever the connection changes, which transitively invalidates the schema
/// cache and any running queries.

final class ActiveAdapterProvider
    extends
        $FunctionalProvider<DatabaseAdapter, DatabaseAdapter, DatabaseAdapter>
    with $Provider<DatabaseAdapter> {
  /// The live adapter for the active connection.
  ///
  /// Throws [StateError] when no connection is open, so dependent providers
  /// surface a clean error state rather than silently doing nothing. Recomputes
  /// whenever the connection changes, which transitively invalidates the schema
  /// cache and any running queries.
  ActiveAdapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeAdapterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeAdapterHash();

  @$internal
  @override
  $ProviderElement<DatabaseAdapter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DatabaseAdapter create(Ref ref) {
    return activeAdapter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DatabaseAdapter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DatabaseAdapter>(value),
    );
  }
}

String _$activeAdapterHash() => r'3136e94e4889453f06189dde9d009f01cdb201a8';
