import 'package:flutter/material.dart';
import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/juno_colors.dart';

/// A pre-flight warning shown when a write/DDL statement is about to run on a
/// read-only connection (plan §4, Layer 2 — UX only).
///
/// The server-side guarantee still rejects the write; this just gives friendly,
/// immediate feedback instead of letting a raw Postgres error be the first
/// thing the user sees. Returns `true` if the user chooses to run anyway.
class WriteWarningDialog extends StatelessWidget {
  /// Creates the dialog for [keyword] (the offending first keyword, e.g.
  /// `UPDATE`).
  const WriteWarningDialog({required this.keyword, super.key});

  /// The statement's first keyword, upper-cased for display.
  final String keyword;

  /// Shows the dialog; resolves to `true` when the user runs anyway.
  static Future<bool> show(
    BuildContext context, {
    required String keyword,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => WriteWarningDialog(keyword: keyword),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;
    return AlertDialog(
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
      icon: Icon(Icons.lock_outline_rounded, color: colors.danger),
      title: const Text('Read-only connection'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'This looks like a $keyword statement, but this connection is '
            'read-only. The server will reject it.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You can still run it to see the error.',
            style: theme.textTheme.bodySmall?.copyWith(color: colors.textMuted),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: colors.danger),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Run anyway'),
        ),
      ],
    );
  }
}
