import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';

class NutriFlowApp extends StatelessWidget {
  const NutriFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriFlow',
      debugShowCheckedModeBanner: false,
      theme: NutriFlowTheme.light(),
      darkTheme: NutriFlowTheme.dark(),
      themeMode: ThemeMode.system,
      home: const _AuthGate(),
    );
  }
}

/// Routes signed-in users to the app, everyone else to [LoginScreen].
/// `main()` mounts `ClerkAuth`/`bootstrapSupabase` before `runApp`, so the
/// Clerk session (if any) is already restored from disk by the time this
/// builds - there's no separate "loading session" state to render here.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return ClerkAuthBuilder(
      signedInBuilder: (context, authState) => const DashboardScreen(),
      signedOutBuilder: (context, authState) => const LoginScreen(),
      builder: (context, authState) => const LoginScreen(),
    );
  }
}
