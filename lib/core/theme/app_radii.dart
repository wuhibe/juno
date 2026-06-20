import 'package:flutter/widgets.dart';

/// Corner-radius scale for Juno, with ready-made [BorderRadius] helpers.
///
/// Mirrors the radii used across the design system (subtle on dense controls,
/// rounder on chips and sheets, fully pill-shaped on tags).
abstract final class AppRadii {
  /// 6px — inputs, small buttons, grid cells.
  static const double sm = 6;

  /// 10px — cards, list rows.
  static const double md = 10;

  /// 12px — larger cards, panels.
  static const double lg = 12;

  /// 16px — snippet chips, bottom sheets.
  static const double xl = 16;

  /// 999px — fully rounded pills / environment tags.
  static const double pill = 999;

  /// [BorderRadius] for [sm].
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));

  /// [BorderRadius] for [md].
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));

  /// [BorderRadius] for [lg].
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));

  /// [BorderRadius] for [xl].
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));

  /// [BorderRadius] for [pill]-shaped elements.
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}
