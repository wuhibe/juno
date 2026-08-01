import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:juno/core/branding/juno_logo.dart';
import 'package:juno/core/router/app_router.dart';
import 'package:juno/core/theme/app_radii.dart';
import 'package:juno/core/theme/app_spacing.dart';
import 'package:juno/core/theme/juno_colors.dart';
import 'package:juno/core/update/update_banner.dart';
import 'package:juno/data/data_providers.dart';
import 'package:juno/data/models/saved_connection.dart';
import 'package:juno/features/connections/application/active_connection_provider.dart';
import 'package:juno/features/connections/presentation/widgets/connection_card.dart';

/// The app home: the list of saved connections.
class ConnectionsListScreen extends ConsumerWidget {
  /// Creates the connections list screen.
  const ConnectionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionsAsync = ref.watch(connectionsListProvider);

    // React to connection lifecycle: open the workspace on success, surface a
    // friendly error on failure.
    ref.listen(activeConnectionProvider, (previous, next) {
      if (next is ConnectionConnected) {
        context.goNamed(
          AppRoute.workspace.name,
          pathParameters: <String, String>{'id': next.connectionId},
        );
      } else if (next is ConnectionFailed) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error.message)));
      }
    });

    final activeState = ref.watch(activeConnectionProvider);
    final connectingId = activeState is ConnectionConnecting
        ? activeState.connectionId
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            JunoLogo(size: 40),
            SizedBox(width: AppSpacing.xxs),
            Text('Juno'),
          ],
        ),
      ),
      floatingActionButton: connectionsAsync.maybeWhen(
        data: (list) => list.isEmpty
            ? null
            : FloatingActionButton.extended(
                onPressed: () => context.pushNamed(AppRoute.connectionNew.name),
                icon: const Icon(Icons.add_rounded),
                label: const Text('New connection'),
              ),
        orElse: () => null,
      ),
      body: Column(
        children: <Widget>[
          const UpdateBanner(),
          Expanded(child: _list(context, ref, connectionsAsync, connectingId)),
        ],
      ),
    );
  }

  Widget _list(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SavedConnection>> connectionsAsync,
    String? connectingId,
  ) {
    return connectionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorState(message: '$error'),
      data: (connections) {
        if (connections.isEmpty) {
          return const _EmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: connections.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final connection = connections[index];
            return ConnectionCard(
              connection: connection,
              isConnecting: connection.id == connectingId,
              onTap: () => ref
                  .read(activeConnectionProvider.notifier)
                  .connect(connection.id),
              onAction: (action) =>
                  _handleAction(context, ref, connection, action),
            );
          },
        );
      },
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    SavedConnection connection,
    ConnectionCardAction action,
  ) async {
    final repo = ref.read(connectionsRepositoryProvider);
    switch (action) {
      case ConnectionCardAction.edit:
        await context.pushNamed(
          AppRoute.connectionEdit.name,
          pathParameters: <String, String>{'id': connection.id},
        );
      case ConnectionCardAction.duplicate:
        await repo.duplicate(connection.id);
      case ConnectionCardAction.delete:
        final confirmed = await _confirmDelete(context, connection);
        if (confirmed) {
          await repo.delete(connection.id);
        }
    }
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    SavedConnection connection,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete connection?'),
        content: Text(
          '"${connection.name}" and its saved password and history will be '
          'removed. This cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).juno.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.juno;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: AppRadii.xlAll,
                border: Border.all(color: colors.border),
              ),
              child: const JunoLogo(size: 56),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('No connections yet', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add a PostgreSQL connection to start browsing\n'
              'schemas and running queries.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton.icon(
              onPressed: () => context.pushNamed(AppRoute.connectionNew.name),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New connection'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).juno;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.error_outline_rounded, color: colors.danger, size: 40),
            const SizedBox(height: AppSpacing.lg),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
