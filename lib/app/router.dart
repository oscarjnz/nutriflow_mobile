import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/logging/barcode_scan_screen.dart';
import '../features/logging/logging_screen.dart';

/// `/log` assumes an authenticated session - it's only reachable by
/// navigating from [DashboardScreen], which is itself gated by [_AuthGate].
/// No redirect logic lives here; auth gating stays a plain widget swap on
/// `/` rather than a `GoRouter.redirect`, since that's what already worked
/// (see CLAUDE.md 2026-07-16 bitacora) and there's no reason to touch it.
final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const _AuthGate()),
    GoRoute(path: '/log', builder: (context, state) => const LoggingScreen()),
    GoRoute(path: '/log/barcode', builder: (context, state) => const BarcodeScanScreen()),
  ],
);

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
