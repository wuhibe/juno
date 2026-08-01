// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_checker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The available update, or null when up to date, unreachable, or off Android.
///
/// Never throws: a failed update check must not interrupt someone trying to
/// query a database. Checked once per app launch (the provider is not
/// refreshed elsewhere).

@ProviderFor(availableUpdate)
final availableUpdateProvider = AvailableUpdateProvider._();

/// The available update, or null when up to date, unreachable, or off Android.
///
/// Never throws: a failed update check must not interrupt someone trying to
/// query a database. Checked once per app launch (the provider is not
/// refreshed elsewhere).

final class AvailableUpdateProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppUpdate?>,
          AppUpdate?,
          FutureOr<AppUpdate?>
        >
    with $FutureModifier<AppUpdate?>, $FutureProvider<AppUpdate?> {
  /// The available update, or null when up to date, unreachable, or off Android.
  ///
  /// Never throws: a failed update check must not interrupt someone trying to
  /// query a database. Checked once per app launch (the provider is not
  /// refreshed elsewhere).
  AvailableUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableUpdateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableUpdateHash();

  @$internal
  @override
  $FutureProviderElement<AppUpdate?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AppUpdate?> create(Ref ref) {
    return availableUpdate(ref);
  }
}

String _$availableUpdateHash() => r'3bd3929830d7721c4361d47d6bb3a856ba623ed0';
