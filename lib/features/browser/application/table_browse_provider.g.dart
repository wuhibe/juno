// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_browse_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Browses `schema.table` with server-side filtering, sorting, and paging.
///
/// Every statement is built by the adapter from [ColumnFilter]/[ColumnSort]
/// specs, so no SQL is assembled here and filter values travel as bound
/// parameters.

@ProviderFor(TableBrowse)
final tableBrowseProvider = TableBrowseFamily._();

/// Browses `schema.table` with server-side filtering, sorting, and paging.
///
/// Every statement is built by the adapter from [ColumnFilter]/[ColumnSort]
/// specs, so no SQL is assembled here and filter values travel as bound
/// parameters.
final class TableBrowseProvider
    extends $NotifierProvider<TableBrowse, TableBrowseState> {
  /// Browses `schema.table` with server-side filtering, sorting, and paging.
  ///
  /// Every statement is built by the adapter from [ColumnFilter]/[ColumnSort]
  /// specs, so no SQL is assembled here and filter values travel as bound
  /// parameters.
  TableBrowseProvider._({
    required TableBrowseFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'tableBrowseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tableBrowseHash();

  @override
  String toString() {
    return r'tableBrowseProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  TableBrowse create() => TableBrowse();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TableBrowseState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TableBrowseState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TableBrowseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tableBrowseHash() => r'39cd8ac91a790facfdc68032a305b0170b489fe6';

/// Browses `schema.table` with server-side filtering, sorting, and paging.
///
/// Every statement is built by the adapter from [ColumnFilter]/[ColumnSort]
/// specs, so no SQL is assembled here and filter values travel as bound
/// parameters.

final class TableBrowseFamily extends $Family
    with
        $ClassFamilyOverride<
          TableBrowse,
          TableBrowseState,
          TableBrowseState,
          TableBrowseState,
          (String, String)
        > {
  TableBrowseFamily._()
    : super(
        retry: null,
        name: r'tableBrowseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Browses `schema.table` with server-side filtering, sorting, and paging.
  ///
  /// Every statement is built by the adapter from [ColumnFilter]/[ColumnSort]
  /// specs, so no SQL is assembled here and filter values travel as bound
  /// parameters.

  TableBrowseProvider call(String schema, String table) =>
      TableBrowseProvider._(argument: (schema, table), from: this);

  @override
  String toString() => r'tableBrowseProvider';
}

/// Browses `schema.table` with server-side filtering, sorting, and paging.
///
/// Every statement is built by the adapter from [ColumnFilter]/[ColumnSort]
/// specs, so no SQL is assembled here and filter values travel as bound
/// parameters.

abstract class _$TableBrowse extends $Notifier<TableBrowseState> {
  late final _$args = ref.$arg as (String, String);
  String get schema => _$args.$1;
  String get table => _$args.$2;

  TableBrowseState build(String schema, String table);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TableBrowseState, TableBrowseState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TableBrowseState, TableBrowseState>,
              TableBrowseState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
