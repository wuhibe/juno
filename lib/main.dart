import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:juno/core/router/app_router.dart';
import 'package:juno/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: JunoApp()));
}

/// Root of the Juno application.
class JunoApp extends ConsumerWidget {
  /// Creates the app.
  const JunoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
