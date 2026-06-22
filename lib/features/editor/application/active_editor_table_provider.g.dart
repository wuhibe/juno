// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_editor_table_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The table the snippet toolbar currently offers column chips for.
///
/// Set when the user picks a table from the `FROM` quick-pick sheet or taps a
/// table chip; cleared when the connection changes (the provider is rebuilt).

@ProviderFor(ActiveEditorTable)
final activeEditorTableProvider = ActiveEditorTableProvider._();

/// The table the snippet toolbar currently offers column chips for.
///
/// Set when the user picks a table from the `FROM` quick-pick sheet or taps a
/// table chip; cleared when the connection changes (the provider is rebuilt).
final class ActiveEditorTableProvider
    extends $NotifierProvider<ActiveEditorTable, DbTable?> {
  /// The table the snippet toolbar currently offers column chips for.
  ///
  /// Set when the user picks a table from the `FROM` quick-pick sheet or taps a
  /// table chip; cleared when the connection changes (the provider is rebuilt).
  ActiveEditorTableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeEditorTableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeEditorTableHash();

  @$internal
  @override
  ActiveEditorTable create() => ActiveEditorTable();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DbTable? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DbTable?>(value),
    );
  }
}

String _$activeEditorTableHash() => r'706b812ead505dc52166a46c43f91d83da534662';

/// The table the snippet toolbar currently offers column chips for.
///
/// Set when the user picks a table from the `FROM` quick-pick sheet or taps a
/// table chip; cleared when the connection changes (the provider is rebuilt).

abstract class _$ActiveEditorTable extends $Notifier<DbTable?> {
  DbTable? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DbTable?, DbTable?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DbTable?, DbTable?>,
              DbTable?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
