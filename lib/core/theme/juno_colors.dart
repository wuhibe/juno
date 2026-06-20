import 'package:flutter/material.dart';

import 'package:juno/core/theme/app_colors.dart';

/// Themed access to Juno's extended palette — the surface elevations, content
/// tiers, and semantic SQL-syntax colors that Material's [ColorScheme] doesn't
/// model well.
///
/// Read it in widgets with `Theme.of(context).juno` (see the extension getter
/// at the bottom of this file). Backing values default to [AppColors], but
/// routing them through a [ThemeExtension] means a future light theme — or a
/// per-connection accent tint — is a drop-in change rather than a refactor.
@immutable
class JunoColors extends ThemeExtension<JunoColors> {
  const JunoColors({
    required this.canvas,
    required this.surface,
    required this.surfaceAlt,
    required this.elevated,
    required this.border,
    required this.borderSoft,
    required this.textPrimary,
    required this.textMuted,
    required this.textFaint,
    required this.accent,
    required this.onAccent,
    required this.keyword,
    required this.operator,
    required this.value,
    required this.schema,
    required this.danger,
    required this.success,
  });

  /// The dark palette, sourced from [AppColors].
  factory JunoColors.dark() => const JunoColors(
    canvas: AppColors.canvas,
    surface: AppColors.surface,
    surfaceAlt: AppColors.surfaceAlt,
    elevated: AppColors.elevated,
    border: AppColors.border,
    borderSoft: AppColors.borderSoft,
    textPrimary: AppColors.textPrimary,
    textMuted: AppColors.textMuted,
    textFaint: AppColors.textFaint,
    accent: AppColors.accent,
    onAccent: AppColors.onAccent,
    keyword: AppColors.keyword,
    operator: AppColors.operator,
    value: AppColors.value,
    schema: AppColors.schema,
    danger: AppColors.danger,
    success: AppColors.success,
  );

  /// Deepest backdrop behind the scaffold background.
  final Color canvas;

  /// Cards, sheets, editor surface.
  final Color surface;

  /// Slightly raised surfaces (elevated rows, grid headers, inputs).
  final Color surfaceAlt;

  /// Most elevated surface (menus, popovers, pressed chips).
  final Color elevated;

  /// Default hairline border.
  final Color border;

  /// Softer, lower-contrast border.
  final Color borderSoft;

  /// Primary text/icons.
  final Color textPrimary;

  /// Secondary/supporting text.
  final Color textMuted;

  /// Tertiary text (placeholders, disabled, faint hints).
  final Color textFaint;

  /// Primary interactive accent.
  final Color accent;

  /// Foreground on top of an [accent] fill.
  final Color onAccent;

  /// SQL keyword color (violet).
  final Color keyword;

  /// SQL operator color (amber).
  final Color operator;

  /// SQL value/literal color (teal).
  final Color value;

  /// Schema-object color: tables/columns/aliases (green).
  final Color schema;

  /// Error / prod-tag / write-warning color (red).
  final Color danger;

  /// Success color (green).
  final Color success;

  @override
  JunoColors copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceAlt,
    Color? elevated,
    Color? border,
    Color? borderSoft,
    Color? textPrimary,
    Color? textMuted,
    Color? textFaint,
    Color? accent,
    Color? onAccent,
    Color? keyword,
    Color? operator,
    Color? value,
    Color? schema,
    Color? danger,
    Color? success,
  }) => JunoColors(
    canvas: canvas ?? this.canvas,
    surface: surface ?? this.surface,
    surfaceAlt: surfaceAlt ?? this.surfaceAlt,
    elevated: elevated ?? this.elevated,
    border: border ?? this.border,
    borderSoft: borderSoft ?? this.borderSoft,
    textPrimary: textPrimary ?? this.textPrimary,
    textMuted: textMuted ?? this.textMuted,
    textFaint: textFaint ?? this.textFaint,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    keyword: keyword ?? this.keyword,
    operator: operator ?? this.operator,
    value: value ?? this.value,
    schema: schema ?? this.schema,
    danger: danger ?? this.danger,
    success: success ?? this.success,
  );

  @override
  JunoColors lerp(covariant JunoColors? other, double t) {
    if (other == null) {
      return this;
    }
    return JunoColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      elevated: Color.lerp(elevated, other.elevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSoft: Color.lerp(borderSoft, other.borderSoft, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      keyword: Color.lerp(keyword, other.keyword, t)!,
      operator: Color.lerp(operator, other.operator, t)!,
      value: Color.lerp(value, other.value, t)!,
      schema: Color.lerp(schema, other.schema, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

/// Ergonomic access to [JunoColors] from any [BuildContext].
extension JunoColorsX on ThemeData {
  /// The registered [JunoColors] extension (always present in Juno themes).
  JunoColors get juno => extension<JunoColors>()!;
}
