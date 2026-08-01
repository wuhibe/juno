import 'package:flutter/material.dart';

import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/juno_colors.dart';

/// A bottom sheet explaining what read-only mode does — and, honestly, what it
/// does not: it is a seatbelt against accidental writes, not a vault.
class ReadOnlyExplainerSheet extends StatelessWidget {
  /// Creates the explainer sheet.
  const ReadOnlyExplainerSheet({super.key});

  /// Shows the sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ReadOnlyExplainerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.lock_outline_rounded, color: colors.accent),
                const SizedBox(width: AppSpacing.sm),
                Text('Read-only mode', style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'When enabled, Juno tells PostgreSQL to run every session as a '
              'read-only transaction. The server then rejects INSERT, UPDATE, '
              'DELETE, and DDL at the engine level — including writes hidden '
              'inside CTEs.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Callout(
              icon: Icons.shield_outlined,
              color: colors.operator,
              text:
                  'This protects you from accidental writes. It is not a '
                  'security boundary: anyone with these credentials could turn '
                  'it off. For production, connect with a database role that '
                  'only has SELECT grants.',
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
