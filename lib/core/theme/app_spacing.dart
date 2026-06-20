/// Spacing scale for Juno — a 4px base grid.
///
/// Use these named steps for padding, margins, and gaps instead of magic
/// numbers, the same way you'd reference a Tailwind spacing token. Keeping all
/// layout on one scale is what makes the UI feel rhythmically consistent.
abstract final class AppSpacing {
  /// 2px — hairline gaps, icon nudges.
  static const double xxs = 2;

  /// 4px — tight gaps inside a chip/badge.
  static const double xs = 4;

  /// 8px — default gap between related items.
  static const double sm = 8;

  /// 12px — default internal padding for compact controls.
  static const double md = 12;

  /// 16px — standard content padding / section gap.
  static const double lg = 16;

  /// 20px — comfortable padding for cards.
  static const double xl = 20;

  /// 24px — gap between distinct sections.
  static const double xxl = 24;

  /// 32px — large section separation.
  static const double xxxl = 32;

  /// 48px — page-level vertical rhythm / empty-state spacing.
  static const double huge = 48;
}
