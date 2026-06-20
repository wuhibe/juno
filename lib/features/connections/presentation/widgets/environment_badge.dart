import 'package:flutter/material.dart';

import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/app_typography.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/data/models/saved_connection.dart';

/// A small pill showing a connection's environment. Production is rendered in
/// the danger color as a deliberate caution signal (plan §3).
class EnvironmentBadge extends StatelessWidget {
  /// Creates a badge for [environment].
  const EnvironmentBadge({required this.environment, super.key});

  /// The environment to display.
  final DbEnvironment environment;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    final color = switch (environment) {
      DbEnvironment.prod => colors.danger,
      DbEnvironment.staging => colors.operator,
      DbEnvironment.dev => colors.schema,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: AppRadii.pillAll,
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        environment.name.toUpperCase(),
        style: AppTypography.mono(10, weight: FontWeight.w600, color: color),
      ),
    );
  }
}
