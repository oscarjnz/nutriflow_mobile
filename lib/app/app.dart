import 'package:flutter/material.dart';

import '../core/auth/clerk_error_display.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class NutriFlowApp extends StatelessWidget {
  const NutriFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NutriFlow',
      debugShowCheckedModeBanner: false,
      theme: NutriFlowTheme.light(),
      darkTheme: NutriFlowTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      // Below MaterialApp (so ScaffoldMessenger exists) and below the
      // ClerkAuth widget from main() - the only place both are true. Without
      // it Clerk errors are rethrown and silently swallowed; see
      // core/auth/clerk_error_display.dart.
      builder: (context, child) => ClerkErrorDisplay(child: child!),
    );
  }
}
