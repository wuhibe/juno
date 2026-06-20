import 'package:flutter/material.dart';

import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/core/utils/formatting.dart';
import 'package:juno/data/models/saved_connection.dart';
import 'package:juno/features/connections/domain/connection_kind_descriptor.dart';
import 'package:juno/features/connections/presentation/widgets/environment_badge.dart';

/// Actions offered from a connection card's overflow menu.
enum ConnectionCardAction {
  /// Open the editor for this connection.
  edit,

  /// Duplicate this connection.
  duplicate,

  /// Delete this connection.
  delete,
}

/// A tappable card representing one saved connection.
///
/// Production connections get a red accent treatment (border + glow) so they
/// stand out wherever they appear.
class ConnectionCard extends StatelessWidget {
  /// Creates a connection card.
  const ConnectionCard({
    required this.connection,
    required this.onTap,
    required this.onAction,
    this.isConnecting = false,
    super.key,
  });

  /// The connection to render.
  final SavedConnection connection;

  /// Called when the card body is tapped (connect + open).
  final VoidCallback onTap;

  /// Called when an overflow-menu action is chosen.
  final ValueChanged<ConnectionCardAction> onAction;

  /// Whether a connection attempt for this card is in flight.
  final bool isConnecting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;
    final descriptor = ConnectionKindDescriptor.of(connection.kind);
    final tagColor = colorFromHex(connection.colorTag);
    final isProd = connection.isProd;
    final accent = isProd ? colors.danger : colors.border;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: accent, width: isProd ? 1.5 : 1),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: isConnecting ? null : onTap,
          borderRadius: AppRadii.lgAll,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: <Widget>[
                _LeadingIcon(
                  icon: descriptor.icon,
                  tagColor: tagColor,
                  isConnecting: isConnecting,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _Details(connection: connection)),
                const SizedBox(width: AppSpacing.sm),
                _Trailing(connection: connection, onAction: onAction),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({
    required this.icon,
    required this.tagColor,
    required this.isConnecting,
  });

  final IconData icon;
  final Color? tagColor;
  final bool isConnecting;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    final color = tagColor ?? colors.accent;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      alignment: Alignment.center,
      child: isConnecting
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Icon(icon, size: 22, color: color),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.connection});

  final SavedConnection connection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                connection.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (connection.readOnly) ...<Widget>[
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: colors.textMuted,
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          '${connection.host}:${connection.port}/${connection.database}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            if (connection.environment != null) ...<Widget>[
              EnvironmentBadge(environment: connection.environment!),
              const SizedBox(width: AppSpacing.sm),
            ],
            if (connection.lastUsedAt != null)
              Text(
                relativeTime(connection.lastUsedAt!),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.textFaint,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Trailing extends StatelessWidget {
  const _Trailing({required this.connection, required this.onAction});

  final SavedConnection connection;
  final ValueChanged<ConnectionCardAction> onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    return PopupMenuButton<ConnectionCardAction>(
      icon: Icon(Icons.more_vert_rounded, color: colors.textMuted),
      color: colors.elevated,
      onSelected: onAction,
      itemBuilder: (context) => const <PopupMenuEntry<ConnectionCardAction>>[
        PopupMenuItem<ConnectionCardAction>(
          value: ConnectionCardAction.edit,
          child: Text('Edit'),
        ),
        PopupMenuItem<ConnectionCardAction>(
          value: ConnectionCardAction.duplicate,
          child: Text('Duplicate'),
        ),
        PopupMenuItem<ConnectionCardAction>(
          value: ConnectionCardAction.delete,
          child: Text('Delete'),
        ),
      ],
    );
  }
}
