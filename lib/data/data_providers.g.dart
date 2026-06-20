// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's local database. Kept alive for the app's lifetime; closed on dispose.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// The app's local database. Kept alive for the app's lifetime; closed on dispose.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// The app's local database. Kept alive for the app's lifetime; closed on dispose.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

/// Secure storage for connection passwords.

@ProviderFor(secureCredentialsRepository)
final secureCredentialsRepositoryProvider =
    SecureCredentialsRepositoryProvider._();

/// Secure storage for connection passwords.

final class SecureCredentialsRepositoryProvider
    extends
        $FunctionalProvider<
          SecureCredentialsRepository,
          SecureCredentialsRepository,
          SecureCredentialsRepository
        >
    with $Provider<SecureCredentialsRepository> {
  /// Secure storage for connection passwords.
  SecureCredentialsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureCredentialsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureCredentialsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SecureCredentialsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SecureCredentialsRepository create(Ref ref) {
    return secureCredentialsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureCredentialsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureCredentialsRepository>(value),
    );
  }
}

String _$secureCredentialsRepositoryHash() =>
    r'7d4a97522d7372592d96be516ab542905e2474dc';

/// Repository for saved connections.

@ProviderFor(connectionsRepository)
final connectionsRepositoryProvider = ConnectionsRepositoryProvider._();

/// Repository for saved connections.

final class ConnectionsRepositoryProvider
    extends
        $FunctionalProvider<
          ConnectionsRepository,
          ConnectionsRepository,
          ConnectionsRepository
        >
    with $Provider<ConnectionsRepository> {
  /// Repository for saved connections.
  ConnectionsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConnectionsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConnectionsRepository create(Ref ref) {
    return connectionsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionsRepository>(value),
    );
  }
}

String _$connectionsRepositoryHash() =>
    r'79a10fff6f7911caf8ed955ea480ebc1034b677e';

/// Repository for query history.

@ProviderFor(queryHistoryRepository)
final queryHistoryRepositoryProvider = QueryHistoryRepositoryProvider._();

/// Repository for query history.

final class QueryHistoryRepositoryProvider
    extends
        $FunctionalProvider<
          QueryHistoryRepository,
          QueryHistoryRepository,
          QueryHistoryRepository
        >
    with $Provider<QueryHistoryRepository> {
  /// Repository for query history.
  QueryHistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'queryHistoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$queryHistoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<QueryHistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  QueryHistoryRepository create(Ref ref) {
    return queryHistoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QueryHistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QueryHistoryRepository>(value),
    );
  }
}

String _$queryHistoryRepositoryHash() =>
    r'c399551fe44a8a741f92afa24d6f02646c8a17aa';

/// Live list of saved connections for the connection manager.

@ProviderFor(connectionsList)
final connectionsListProvider = ConnectionsListProvider._();

/// Live list of saved connections for the connection manager.

final class ConnectionsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SavedConnection>>,
          List<SavedConnection>,
          Stream<List<SavedConnection>>
        >
    with
        $FutureModifier<List<SavedConnection>>,
        $StreamProvider<List<SavedConnection>> {
  /// Live list of saved connections for the connection manager.
  ConnectionsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionsListHash();

  @$internal
  @override
  $StreamProviderElement<List<SavedConnection>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SavedConnection>> create(Ref ref) {
    return connectionsList(ref);
  }
}

String _$connectionsListHash() => r'c8429fcf14cff6833c3f6677b1a2175749314ffd';
