import 'package:flutter/material.dart';

import 'package:juno/core/theme/app_colors.dart';
import 'package:juno/core/theme/juno_colors.dart';

/// The Juno brand mark, reproduced from the design-system spec.
///
/// A rounded-square head with two ears, two eye holes, and a small tail. Drawn
/// vectorially (no asset) so it scales crisply and re-themes; the same painter
/// also generates the launcher icons (see `tool/generate_launcher_icons`).
class JunoLogo extends StatelessWidget {
  /// Creates the logo at [size] logical pixels square.
  const JunoLogo({
    required this.size,
    this.background,
    this.markColor,
    this.eyeColor,
    super.key,
  });

  /// Edge length (the mark is square).
  final double size;

  /// Optional background fill behind the mark (null = transparent).
  final Color? background;

  /// The mark color (defaults to the theme accent).
  final Color? markColor;

  /// The eye/hole color (defaults to [background], else the canvas color).
  final Color? eyeColor;

  @override
  Widget build(BuildContext context) {
    final JunoColors colors = Theme.of(context).juno;
    return CustomPaint(
      size: Size.square(size),
      painter: JunoLogoPainter(
        background: background,
        markColor: markColor ?? colors.accent,
        eyeColor: eyeColor ?? background ?? colors.canvas,
      ),
    );
  }
}

/// Paints the Juno mark. Coordinates mirror the spec's `viewBox="0 0 100 100"`
/// with the figure group translated to (50, 52).
class JunoLogoPainter extends CustomPainter {
  /// Creates the painter. [markColor] and [eyeColor] are required; [background]
  /// is optional (null leaves it transparent).
  const JunoLogoPainter({
    required this.markColor,
    required this.eyeColor,
    this.background,
  });

  /// Background fill (null = transparent).
  final Color? background;

  /// The mark color.
  final Color markColor;

  /// The eye/hole color.
  final Color eyeColor;

  static const Color _specMark = AppColors.accent;
  static const Color _specCanvas = AppColors.background;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 100;
    final double gx = 50 * s;
    final double gy = 52 * s;
    Offset p(double x, double y) => Offset(gx + x * s, gy + y * s);
    double r(double v) => v * s;

    if (background != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = background!,
      );
    }

    final mark = Paint()
      ..color = markColor
      ..isAntiAlias = true;

    // Ears.
    canvas
      ..drawCircle(p(-13, -9), r(9), mark)
      ..drawCircle(p(13, -9), r(9), mark);

    // Head (rounded square).
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(p(-14.5, -15).dx, p(-14.5, -15).dy, r(29), r(30)),
        Radius.circular(r(14.5)),
      ),
      mark,
    );

    // Tail: M0 13 C0 24 10.5 25 10 16.
    final tail = Path()
      ..moveTo(p(0, 13).dx, p(0, 13).dy)
      ..cubicTo(
        p(0, 24).dx,
        p(0, 24).dy,
        p(10.5, 25).dx,
        p(10.5, 25).dy,
        p(10, 16).dx,
        p(10, 16).dy,
      );
    canvas.drawPath(
      tail,
      Paint()
        ..color = markColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = r(6.5)
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true,
    );

    // Eyes (holes).
    final eyes = Paint()
      ..color = eyeColor
      ..isAntiAlias = true;
    canvas
      ..drawCircle(p(-6, -3), r(2.5), eyes)
      ..drawCircle(p(6, -3), r(2.5), eyes);
  }

  /// The exact colors from the spec (accent mark on the dark canvas), used for
  /// the launcher icons.
  static JunoLogoPainter spec() => const JunoLogoPainter(
    markColor: _specMark,
    eyeColor: _specCanvas,
    background: _specCanvas,
  );

  @override
  bool shouldRepaint(JunoLogoPainter oldDelegate) =>
      oldDelegate.markColor != markColor ||
      oldDelegate.eyeColor != eyeColor ||
      oldDelegate.background != background;
}
