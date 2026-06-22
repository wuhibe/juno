import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:juno/core/router/app_router.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/data/data_providers.dart';
import 'package:juno/features/browser/application/schema_cache_provider.dart';
import 'package:juno/features/browser/presentation/schema_browser.dart';
import 'package:juno/features/connections/application/active_connection_provider.dart';

/// The connected workspace: hosts the schema browser (Phase 4). The SQL editor
/// and results grid are layered in next (Phase 5).
class WorkspaceShellScreen extends ConsumerWidget {
  /// Creates the workspace shell for [connectionId].
  const WorkspaceShellScreen({required this.connectionId, super.key});

  /// The connection this workspace is bound to.
  final String connectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).juno;
    final status = ref.watch(activeConnectionProvider);

    // An explicit disconnect (or a deep link with no live connection) sends the
    // user back to the list.
    if (status is ConnectionIdle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.goNamed(AppRoute.connections.name);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // A transient (re)connect keeps the user in place with a spinner.
    if (status is ConnectionConnecting || status is ConnectionReconnecting) {
      return Scaffold(
        appBar: AppBar(title: Text(_title(ref))),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.lg),
              Text(
                status is ConnectionReconnecting
                    ? 'Reconnecting…'
                    : 'Connecting…',
                style: TextStyle(color: colors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    // The socket died and could not be reopened — offer a retry in place
    // instead of dropping the user back to the list (plan §8.3).
    if (status is ConnectionFailed) {
      return _ConnectionLost(
        title: _title(ref),
        message: status.error.message,
        onRetry: () =>
            ref.read(activeConnectionProvider.notifier).connect(connectionId),
        onLeave: () => context.goNamed(AppRoute.connections.name),
      );
    }

    final showSystem = ref.watch(showSystemSchemasProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(ref)),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              showSystem
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: showSystem ? colors.accent : colors.textMuted,
            ),
            tooltip: showSystem ? 'Hide system schemas' : 'Show system schemas',
            onPressed: () =>
                ref.read(showSystemSchemasProvider.notifier).toggle(),
          ),
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
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(
          AppRoute.editor.name,
          pathParameters: <String, String>{'id': connectionId},
        ),
        icon: const Icon(Icons.code_rounded),
        label: const Text('SQL editor'),
      ),
      body: SchemaBrowser(connectionId: connectionId),
    );
  }

  String _title(WidgetRef ref) {
    final connections = ref.watch(connectionsListProvider).value;
    if (connections != null) {
      for (final connection in connections) {
        if (connection.id == connectionId) {
          return connection.name;
        }
      }
    }
    return 'Workspace';
  }
}

/// Shown when the active connection was lost and the auto-reconnect failed.
class _ConnectionLost extends StatelessWidget {
  const _ConnectionLost({
    required this.title,
    required this.message,
    required this.onRetry,
    required this.onLeave,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.juno;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.cloud_off_rounded, size: 48, color: colors.danger),
              const SizedBox(height: AppSpacing.lg),
              Text('Connection lost', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reconnect'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: onLeave,
                child: const Text('Back to connections'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
