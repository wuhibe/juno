import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/core/update/update_checker.dart';
import 'package:url_launcher/url_launcher.dart';

/// A quiet banner offering the newer release, shown only where the user is not
/// mid-task (the connections list). Renders nothing when up to date.
///
/// Dismissal lasts for the session: the check itself only runs once per launch,
/// so persisting a "skipped version" would cost a schema migration to save one
/// glance at a banner.
class UpdateBanner extends ConsumerStatefulWidget {
  /// Creates the banner.
  const UpdateBanner({super.key});

  @override
  ConsumerState<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends ConsumerState<UpdateBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) {
      return const SizedBox.shrink();
    }
    final update = ref.watch(availableUpdateProvider).asData?.value;
    if (update == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colors = theme.juno;
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.12),
        border: Border.all(color: colors.accent.withValues(alpha: 0.4)),
        borderRadius: AppRadii.mdAll,
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.system_update_rounded, size: 18, color: colors.accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Juno v${update.version} is available',
              style: theme.textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: () => launchUrl(
              update.downloadUrl,
              mode: LaunchMode.externalApplication,
            ),
            child: const Text('Download'),
          ),
          IconButton(
            tooltip: 'Dismiss',
            icon: Icon(Icons.close_rounded, size: 18, color: colors.textMuted),
            onPressed: () => setState(() => _dismissed = true),
          ),
        ],
      ),
    );
  }
}
