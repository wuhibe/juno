// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autocomplete_index_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Flattened table list across all visible (non-system) schemas, eagerly loaded
/// so the editor can offer table suggestions the moment the connection is live
/// — before the user has expanded anything in the schema browser.
///
/// Reuses the keep-alive [tableListProvider] caches, so the browser and the
/// autocomplete engine share one source of truth and a single round of
/// introspection. Columns stay lazy (warmed per referenced table in the editor)
/// to avoid introspecting every table on connect.

@ProviderFor(autocompleteTables)
final autocompleteTablesProvider = AutocompleteTablesProvider._();

/// Flattened table list across all visible (non-system) schemas, eagerly loaded
/// so the editor can offer table suggestions the moment the connection is live
/// — before the user has expanded anything in the schema browser.
///
/// Reuses the keep-alive [tableListProvider] caches, so the browser and the
/// autocomplete engine share one source of truth and a single round of
/// introspection. Columns stay lazy (warmed per referenced table in the editor)
/// to avoid introspecting every table on connect.

final class AutocompleteTablesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DbTable>>,
          List<DbTable>,
          FutureOr<List<DbTable>>
        >
    with $FutureModifier<List<DbTable>>, $FutureProvider<List<DbTable>> {
  /// Flattened table list across all visible (non-system) schemas, eagerly loaded
  /// so the editor can offer table suggestions the moment the connection is live
  /// — before the user has expanded anything in the schema browser.
  ///
  /// Reuses the keep-alive [tableListProvider] caches, so the browser and the
  /// autocomplete engine share one source of truth and a single round of
  /// introspection. Columns stay lazy (warmed per referenced table in the editor)
  /// to avoid introspecting every table on connect.
  AutocompleteTablesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autocompleteTablesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autocompleteTablesHash();

  @$internal
  @override
  $FutureProviderElement<List<DbTable>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DbTable>> create(Ref ref) {
    return autocompleteTables(ref);
  }
}

String _$autocompleteTablesHash() =>
    r'4aaf951e50c71d7cf3b60c03e31c6df0ce6a7438';
