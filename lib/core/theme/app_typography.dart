import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography for Juno.
///
/// Two families, matching the design system:
///  - **Geist** for all UI text.
///  - **JetBrains Mono** for code, SQL, and any tabular/identifier value.
///
/// Fonts are resolved at runtime via `google_fonts` (cached after first load);
/// they can be bundled as assets later for fully offline first-launch.
///
/// Sizes/weights below come straight from the design export. Build the Material
/// [TextTheme] with [textTheme]; reach for [mono] wherever you render SQL or raw
/// cell values.
abstract final class AppTypography {
  static const String uiFamily = 'Geist';
  static const String monoFamily = 'JetBrains Mono';

  static TextStyle _ui(double size, FontWeight weight, {double height = 1.4}) =>
      GoogleFonts.getFont(
        uiFamily,
        fontSize: size,
        fontWeight: weight,
        height: height,
      );

  /// A monospace style for code/SQL/identifiers and raw cell values.
  static TextStyle mono(
    double size, {
    FontWeight weight = FontWeight.w400,
    double height = 1.5,
    Color? color,
  }) => GoogleFonts.getFont(
    monoFamily,
    fontSize: size,
    fontWeight: weight,
    height: height,
    color: color,
  );

  /// The full Material [TextTheme], tinted to [textPrimary] with [textMuted]
  /// applied to the smaller/supporting slots.
  static TextTheme textTheme({
    required Color textPrimary,
    required Color textMuted,
  }) {
    final TextTheme base = TextTheme(
      displayLarge: _ui(34, FontWeight.w700, height: 1.05),
      displayMedium: _ui(28, FontWeight.w700, height: 1.1),
      displaySmall: _ui(24, FontWeight.w600, height: 1.15),
      headlineMedium: _ui(22, FontWeight.w600, height: 1.2),
      headlineSmall: _ui(19, FontWeight.w600, height: 1.25),
      titleLarge: _ui(17, FontWeight.w600),
      titleMedium: _ui(15, FontWeight.w600),
      titleSmall: _ui(13, FontWeight.w600),
      bodyLarge: _ui(15, FontWeight.w400, height: 1.5),
      bodyMedium: _ui(14, FontWeight.w400, height: 1.5),
      bodySmall: _ui(12.5, FontWeight.w400, height: 1.5),
      labelLarge: _ui(13, FontWeight.w500),
      labelMedium: _ui(12, FontWeight.w500),
      labelSmall: _ui(11, FontWeight.w500),
    );
    return base.apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
      decorationColor: textMuted,
    );
  }
}
