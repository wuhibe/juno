import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:juno/core/router/app_router.dart';
import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/features/connections/application/active_connection_provider.dart';

/// The connected workspace.
///
/// In Phase 3 this is the landing surface that proves the connect flow works;
/// Phase 4 fills it with the schema browser and table previews.
class WorkspaceShellScreen extends ConsumerWidget {
  /// Creates the workspace shell for [connectionId].
  const WorkspaceShellScreen({required this.connectionId, super.key});

  /// The connection this workspace is bound to.
  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.juno;
    final status = ref.watch(activeConnectionProvider);

    // If the connection isn't live (e.g. after disconnect or a deep link),
    // send the user back to the list.
    if (status is! ConnectionConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.goNamed(AppRoute.connections.name);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final adapter = status.adapter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.link_off_rounded),
            tooltip: 'Disconnect',
            onPressed: () async {
              await ref.read(activeConnectionProvider.notifier).disconnect();
              if (context.mounted) {
                context.goNamed(AppRoute.connections.name);
              }
            },
          ),
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
                  color: colors.success.withValues(alpha: 0.14),
                  borderRadius: AppRadii.xlAll,
                  border: Border.all(
                    color: colors.success.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 40,
                  color: colors.success,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Connected', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Schema browser and SQL editor arrive next.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (adapter.kind.name.isNotEmpty)
                Text(
                  'Engine: ${adapter.kind.name}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.textFaint,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
