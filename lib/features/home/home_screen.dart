import 'package:flutter/material.dart';

import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/app_typography.dart';
import 'package:juno/core/theme/juno_colors.dart';

/// The app home — currently a themed empty state.
///
/// This is the Phase 0 acceptance surface: it proves the design tokens, fonts,
/// and theme wiring render correctly. It will become the saved-connections list
/// in Phase 3.
class HomeScreen extends StatelessWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final JunoColors c = theme.juno;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Juno'),
        actions: <Widget>[
          IconButton(
            onPressed: null,
            icon: Icon(Icons.add_rounded, color: c.textMuted),
            tooltip: 'New connection',
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: AppRadii.xlAll,
                  border: Border.all(color: c.border),
                ),
                child: Icon(Icons.storage_rounded, size: 40, color: c.accent),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('No connections yet', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Add a PostgreSQL connection to start browsing\nschemas and running queries.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: c.textMuted),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // A small token showcase so the syntax palette is visible in the
              // base build — these become snippet chips in Phase 7.
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  _SyntaxChip(label: 'SELECT', color: c.keyword),
                  _SyntaxChip(label: 'WHERE', color: c.operator),
                  _SyntaxChip(label: "''", color: c.value),
                  _SyntaxChip(label: 'users', color: c.schema),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: null,
        backgroundColor: c.accent,
        foregroundColor: c.onAccent,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New connection'),
      ),
    );
  }
}

/// A preview of a snippet/syntax chip, color-coded by SQL category.
class _SyntaxChip extends StatelessWidget {
  const _SyntaxChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: AppRadii.xlAll,
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: AppTypography.mono(13, weight: FontWeight.w500, color: color),
      ),
    );
  }
}
