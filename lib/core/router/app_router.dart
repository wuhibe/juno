import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:juno/features/browser/presentation/table_browser_screen.dart';
import 'package:juno/features/connections/presentation/connection_editor_screen.dart';
import 'package:juno/features/connections/presentation/connections_list_screen.dart';
import 'package:juno/features/editor/presentation/editor_screen.dart';
import 'package:juno/features/history/presentation/query_history_screen.dart';
import 'package:juno/features/workspace/workspace_shell_screen.dart';

/// Named routes, kept in one enum so navigation never hardcodes strings.
enum AppRoute {
  /// The saved-connections list (home).
  connections('/'),

  /// Create a new connection.
  connectionNew('/connections/new'),

  /// Edit an existing connection (`:id`).
  connectionEdit('/connections/:id/edit'),

  /// The connected workspace (`:id`).
  workspace('/workspace/:id'),

  /// A table browser within a connection (`:id`); target passed via `extra`.
  tableBrowser('/workspace/:id/table'),

  /// The SQL editor for a connection (`:id`).
  editor('/workspace/:id/editor'),

  /// The query history for a connection (`:id`).
  history('/workspace/:id/history');

  const AppRoute(this.path);

  /// The go_router path pattern.
  final String path;
}

/// The app's [GoRouter], exposed as a provider so routes can later depend on
/// app state (e.g. redirecting based on the active connection).
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.connections.path,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoute.connections.path,
        name: AppRoute.connections.name,
        builder: (context, state) => const ConnectionsListScreen(),
      ),
      GoRoute(
        path: AppRoute.connectionNew.path,
        name: AppRoute.connectionNew.name,
        builder: (context, state) => const ConnectionEditorScreen(),
      ),
      GoRoute(
        path: AppRoute.connectionEdit.path,
        name: AppRoute.connectionEdit.name,
        builder: (context, state) =>
            ConnectionEditorScreen(connectionId: state.pathParameters['id']),
      ),
      GoRoute(
        path: AppRoute.workspace.path,
        name: AppRoute.workspace.name,
        builder: (context, state) =>
            WorkspaceShellScreen(connectionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoute.tableBrowser.path,
        name: AppRoute.tableBrowser.name,
        builder: (context, state) =>
            TableBrowserScreen(args: state.extra! as TableBrowserArgs),
      ),
      GoRoute(
        path: AppRoute.editor.path,
        name: AppRoute.editor.name,
        builder: (context, state) =>
            EditorScreen(connectionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoute.history.path,
        name: AppRoute.history.name,
        builder: (context, state) =>
            QueryHistoryScreen(connectionId: state.pathParameters['id']!),
      ),
    ],
  );
});
