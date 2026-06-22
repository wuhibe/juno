// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_draft_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A one-shot channel that hands SQL to the editor from another screen.
///
/// The history screen sets a draft and pops back to the (still-mounted) editor,
/// which consumes it via a listener and clears it.

@ProviderFor(EditorDraftRequest)
final editorDraftRequestProvider = EditorDraftRequestProvider._();

/// A one-shot channel that hands SQL to the editor from another screen.
///
/// The history screen sets a draft and pops back to the (still-mounted) editor,
/// which consumes it via a listener and clears it.
final class EditorDraftRequestProvider
    extends $NotifierProvider<EditorDraftRequest, EditorDraft?> {
  /// A one-shot channel that hands SQL to the editor from another screen.
  ///
  /// The history screen sets a draft and pops back to the (still-mounted) editor,
  /// which consumes it via a listener and clears it.
  EditorDraftRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editorDraftRequestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editorDraftRequestHash();

  @$internal
  @override
  EditorDraftRequest create() => EditorDraftRequest();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditorDraft? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditorDraft?>(value),
    );
  }
}

String _$editorDraftRequestHash() =>
    r'cfd4a9a4a422d74f995407f227b3f0fa2401df48';

/// A one-shot channel that hands SQL to the editor from another screen.
///
/// The history screen sets a draft and pops back to the (still-mounted) editor,
/// which consumes it via a listener and clears it.

abstract class _$EditorDraftRequest extends $Notifier<EditorDraft?> {
  EditorDraft? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<EditorDraft?, EditorDraft?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EditorDraft?, EditorDraft?>,
              EditorDraft?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
