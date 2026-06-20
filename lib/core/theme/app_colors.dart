import 'package:flutter/widgets.dart';

/// Raw color tokens for Juno — the single source of truth for every color in
/// the app, mirrored from the `Juno Design System` export.
///
/// Think of this class as the project's `tailwind.config` color section: nothing
/// in the UI should hardcode a `Color(0x...)`. Reference a named token here, or
/// — preferably, for widgets — read the themed [JunoColors] extension so the
/// app can support alternate themes later.
///
/// The palette is dark-base with colorful, semantic accents. The accent hues map
/// 1:1 to SQL syntax categories so the snippet chips and the code editor's
/// highlighting read as one system (keyword=violet, operator=amber, value=teal,
/// schema=green).
abstract final class AppColors {
  // --- Surfaces (dark, low → high elevation) ---

  /// The deepest backdrop, behind [background] (e.g. behind sheets, gutters).
  static const Color canvas = Color(0xFF080A0F);

  /// Default app/scaffold background.
  static const Color background = Color(0xFF0E121A);

  /// Cards, sheets, the editor surface.
  static const Color surface = Color(0xFF161B26);

  /// Slightly raised surfaces: elevated rows, grid headers, inputs.
  static const Color surfaceAlt = Color(0xFF1E2533);

  /// The most elevated surface: menus, popovers, pressed chips.
  static const Color elevated = Color(0xFF232C3D);

  /// Default hairline border between surfaces.
  static const Color border = Color(0xFF2B3343);

  /// A softer, lower-contrast border for subtle dividers.
  static const Color borderSoft = Color(0xFF1F2735);

  // --- Content (text & icons) ---

  /// Primary text and icons.
  static const Color textPrimary = Color(0xFFE7ECF3);

  /// Secondary / supporting text (labels, captions, metadata).
  static const Color textMuted = Color(0xFF8B95A6);

  /// Tertiary text: placeholders, disabled, the faintest hints.
  static const Color textFaint = Color(0xFF5C6675);

  // --- Brand accent ---

  /// Primary interactive accent (buttons, links, focus, selection).
  static const Color accent = Color(0xFF5B9CFF);

  /// Foreground used on top of an [accent]-filled surface.
  static const Color onAccent = Color(0xFF081019);

  // --- Semantic / SQL-syntax palette (the colorful part) ---

  /// Keywords: `SELECT`, `FROM`, `WHERE`, … (violet).
  static const Color keyword = Color(0xFFA78BFA);

  /// Operators: `=`, `LIKE`, `AND`, … (amber).
  static const Color operator = Color(0xFFF2B45A);

  /// Values & literals: `''`, `()`, `*`, `;`, numbers (teal).
  static const Color value = Color(0xFF33CFC9);

  /// Schema objects: table / column / alias smart chips (green).
  static const Color schema = Color(0xFF7DDC8E);

  /// Errors, the `prod` environment tag, write-warning affordances (red).
  static const Color danger = Color(0xFFFF6259);

  /// Success states: connected, query OK (green).
  static const Color success = Color(0xFF46C26A);
}
