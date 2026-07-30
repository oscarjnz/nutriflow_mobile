import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/api/providers.dart';
import '../features/auth/login_screen.dart';
import '../features/body_metrics/weight_log_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/logging/barcode_scan_screen.dart';
import '../features/logging/logging_screen.dart';
import '../features/onboarding/onboarding_screen.dart';

/// `/log` and `/onboarding` assume an authenticated session - they're only
/// reachable via [_AuthGate]/[_OnboardingGate]. No redirect logic lives
/// here; auth gating stays a plain widget swap on `/` rather than a
/// `GoRouter.redirect`, since that's what already worked (see CLAUDE.md
/// 2026-07-16 bitacora) and there's no reason to touch it.
final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const _AuthGate()),
    GoRoute(path: '/log', builder: (context, state) => const LoggingScreen()),
    GoRoute(path: '/log/barcode', builder: (context, state) => const BarcodeScanScreen()),
    GoRoute(path: '/weight', builder: (context, state) => const WeightLogScreen()),
  ],
);

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return ClerkAuthBuilder(
      signedInBuilder: (context, authState) => const _OnboardingGate(),
      signedOutBuilder: (context, authState) => const LoginScreen(),
      builder: (context, authState) => const LoginScreen(),
    );
  }
}

/// Routes a signed-in user to [OnboardingScreen] (no completed profile yet)
/// or [DashboardScreen] (already onboarded) - `GET /api/onboarding/status`,
/// mirroring the `profile?.onboardingCompleted` check
/// `nutriflow/src/app/onboarding/page.tsx` does server-side on web.
class _OnboardingGate extends ConsumerWidget {
  const _OnboardingGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(onboardingStatusProvider);
    return status.when(
      data: (completed) => completed ? const DashboardScreen() : const OnboardingScreen(),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No pudimos verificar tu perfil.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(onboardingStatusProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
