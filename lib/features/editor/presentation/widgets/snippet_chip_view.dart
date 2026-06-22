import 'package:flutter/material.dart';
import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/app_typography.dart';

/// A single snippet chip rendered per the plan §8 anatomy: 32px tall, 16px
/// radius, category-colour background at ~18% opacity with a 1px category-colour
/// border and a monospace label in the full category colour. Pressed state
/// inverts to a full-opacity background with dark text.
class SnippetChipView extends StatefulWidget {
  /// Creates a chip showing [label] in [color].
  const SnippetChipView({
    required this.label,
    required this.color,
    required this.pressedTextColor,
    required this.onTap,
    this.onLongPress,
    this.hasMenu = false,
    super.key,
  });

  /// The chip label.
  final String label;

  /// The category colour.
  final Color color;

  /// Text colour while pressed (a dark surface colour for contrast).
  final Color pressedTextColor;

  /// Insert handler.
  final VoidCallback onTap;

  /// Optional long-press handler (variant menu / pin).
  final VoidCallback? onLongPress;

  /// Whether to show a small caret hinting at a long-press menu.
  final bool hasMenu;

  @override
  State<SnippetChipView> createState() => _SnippetChipViewState();
}

class _SnippetChipViewState extends State<SnippetChipView> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: _pressed ? color : color.withValues(alpha: 0.18),
          borderRadius: AppRadii.xlAll,
          border: Border.all(color: color),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.label,
              style: AppTypography.mono(
                13,
                color: _pressed ? widget.pressedTextColor : color,
              ),
            ),
            if (widget.hasMenu) ...<Widget>[
              const SizedBox(width: AppSpacing.xxs),
              Icon(
                Icons.arrow_drop_down,
                size: 14,
                color: _pressed ? widget.pressedTextColor : color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
