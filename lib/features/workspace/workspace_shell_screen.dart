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
