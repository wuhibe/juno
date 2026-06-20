import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:juno/features/home/home_screen.dart';

/// Named route paths, kept in one place so navigation never hardcodes strings.
abstract final class AppRoutes {
  /// The connections list / app home.
  static const String home = '/';
}

/// The app's [GoRouter], exposed as a Riverpod provider so routes can later
/// depend on app state (e.g. redirecting based on the active connection).
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
