// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema_cache_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether engine-internal schemas (`pg_catalog`, `information_schema`, `pg_*`)
/// are shown in the browser.

@ProviderFor(ShowSystemSchemas)
final showSystemSchemasProvider = ShowSystemSchemasProvider._();

/// Whether engine-internal schemas (`pg_catalog`, `information_schema`, `pg_*`)
/// are shown in the browser.
final class ShowSystemSchemasProvider
    extends $NotifierProvider<ShowSystemSchemas, bool> {
  /// Whether engine-internal schemas (`pg_catalog`, `information_schema`, `pg_*`)
  /// are shown in the browser.
  ShowSystemSchemasProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showSystemSchemasProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showSystemSchemasHash();

  @$internal
  @override
  ShowSystemSchemas create() => ShowSystemSchemas();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showSystemSchemasHash() => r'7f0667c3c4ce7a8802fd1e7e1ad5ee98292ce22f';

/// Whether engine-internal schemas (`pg_catalog`, `information_schema`, `pg_*`)
/// are shown in the browser.

abstract class _$ShowSystemSchemas extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Cached schema list for the active connection. Recomputed when the connection
/// changes or the system-schemas toggle flips.

@ProviderFor(schemaList)
final schemaListProvider = SchemaListProvider._();

/// Cached schema list for the active connection. Recomputed when the connection
/// changes or the system-schemas toggle flips.

final class SchemaListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DbSchema>>,
          List<DbSchema>,
          FutureOr<List<DbSchema>>
        >
    with $FutureModifier<List<DbSchema>>, $FutureProvider<List<DbSchema>> {
  /// Cached schema list for the active connection. Recomputed when the connection
  /// changes or the system-schemas toggle flips.
  SchemaListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'schemaListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$schemaListHash();

  @$internal
  @override
  $FutureProviderElement<List<DbSchema>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DbSchema>> create(Ref ref) {
    return schemaList(ref);
  }
}

String _$schemaListHash() => r'182f212438acd234fda8f7e0922edf5ad8c2eb8e';

/// Cached table list for [schema] (lazy: only loaded once a schema is expanded).

@ProviderFor(tableList)
final tableListProvider = TableListFamily._();

/// Cached table list for [schema] (lazy: only loaded once a schema is expanded).

final class TableListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DbTable>>,
          List<DbTable>,
          FutureOr<List<DbTable>>
        >
    with $FutureModifier<List<DbTable>>, $FutureProvider<List<DbTable>> {
  /// Cached table list for [schema] (lazy: only loaded once a schema is expanded).
  TableListProvider._({
    required TableListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tableListProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tableListHash();

  @override
  String toString() {
    return r'tableListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DbTable>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DbTable>> create(Ref ref) {
    final argument = this.argument as String;
    return tableList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TableListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tableListHash() => r'3514adc49ce755d86de6eedbe11a39b86a217150';

/// Cached table list for [schema] (lazy: only loaded once a schema is expanded).

final class TableListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DbTable>>, String> {
  TableListFamily._()
    : super(
        retry: null,
        name: r'tableListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Cached table list for [schema] (lazy: only loaded once a schema is expanded).

  TableListProvider call(String schema) =>
      TableListProvider._(argument: schema, from: this);

  @override
  String toString() => r'tableListProvider';
}

/// Cached column list for [schema].[table] (lazy: loaded on table expand).
/// Shared with the schema browser and (later) the autocomplete engine.

@ProviderFor(columnList)
final columnListProvider = ColumnListFamily._();

/// Cached column list for [schema].[table] (lazy: loaded on table expand).
/// Shared with the schema browser and (later) the autocomplete engine.

final class ColumnListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DbColumn>>,
          List<DbColumn>,
          FutureOr<List<DbColumn>>
        >
    with $FutureModifier<List<DbColumn>>, $FutureProvider<List<DbColumn>> {
  /// Cached column list for [schema].[table] (lazy: loaded on table expand).
  /// Shared with the schema browser and (later) the autocomplete engine.
  ColumnListProvider._({
    required ColumnListFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'columnListProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$columnListHash();

  @override
  String toString() {
    return r'columnListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<DbColumn>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DbColumn>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return columnList(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ColumnListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$columnListHash() => r'c31675c2308cb3012dc7cf9b35571253a10fa4bf';

/// Cached column list for [schema].[table] (lazy: loaded on table expand).
/// Shared with the schema browser and (later) the autocomplete engine.

final class ColumnListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DbColumn>>, (String, String)> {
  ColumnListFamily._()
    : super(
        retry: null,
        name: r'columnListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Cached column list for [schema].[table] (lazy: loaded on table expand).
  /// Shared with the schema browser and (later) the autocomplete engine.

  ColumnListProvider call(String schema, String table) =>
      ColumnListProvider._(argument: (schema, table), from: this);

  @override
  String toString() => r'columnListProvider';
}
