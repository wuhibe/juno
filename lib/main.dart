import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:juno/core/router/app_router.dart';
import 'package:juno/core/theme/app_theme.dart';
import 'package:juno/features/connections/application/active_connection_provider.dart';

void main() {
  runApp(const ProviderScope(child: JunoApp()));
}

/// Root of the Juno application.
///
/// Owns the app-lifecycle listener: mobile OSes kill idle TCP sockets while
/// backgrounded, so every resume triggers a liveness check + silent reconnect
/// on the active connection.
class JunoApp extends ConsumerStatefulWidget {
  /// Creates the app.
  const JunoApp({super.key});

  @override
  ConsumerState<JunoApp> createState() => _JunoAppState();
}

class _JunoAppState extends ConsumerState<JunoApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () =>
          ref.read(activeConnectionProvider.notifier).pingOrReconnect(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Juno',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
