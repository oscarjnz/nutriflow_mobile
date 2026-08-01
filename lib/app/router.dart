import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/api/nutriflow_api.dart';
import '../core/api/providers.dart';
import '../features/auth/login_screen.dart';
import '../features/body_metrics/weight_log_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/fasting/fasting_screen.dart';
import '../features/logging/barcode_scan_screen.dart';
import '../features/logging/logging_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';

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
    GoRoute(path: '/calendar', builder: (context, state) => const CalendarScreen()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    GoRoute(path: '/fasting', builder: (context, state) => const FastingScreen()),
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
      error: (error, stackTrace) {
        // Never swallow this (CLAUDE.md section 9). A generic "no pudimos
        // verificar tu perfil" hid a paused Supabase project for a whole
        // debugging session once; the cause has to be readable on screen.
        debugPrint('[onboarding-gate] $error\n$stackTrace');
        return _GateErrorScreen(
          error: error,
          onRetry: () => ref.invalidate(onboardingStatusProvider),
        );
      },
    );
  }
}

/// Failure state for [_OnboardingGate]. Shows what actually went wrong instead
/// of a generic message: the two realistic causes here (the nutriflow dev
/// server not running, and a paused Supabase project) look identical to the
/// user otherwise, and telling them apart from a phone or a demo machine
/// without a console is impossible.
class _GateErrorScreen extends StatelessWidget {
  const _GateErrorScreen({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.cloudOff,
                  size: 40,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No pudimos verificar tu perfil',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _explain(error),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Maps the failure to the operator action that fixes it. Status codes come
  /// from the route handlers in `nutriflow/src/app/api/*`.
  static String _explain(Object error) {
    if (error is! ApiFailure) return error.toString();
    return switch (error.statusCode) {
      500 || 502 || 503 =>
        'El servidor respondio ${error.statusCode}. Suele ser la base de datos '
            'de Supabase pausada por inactividad: reactivala en el dashboard.',
      401 || 403 => 'Tu sesion no fue aceptada por el servidor. Cierra sesion '
          'y vuelve a entrar.',
      404 => 'El endpoint no existe en el servidor de nutriflow. Revisa que '
          'este corriendo la version correcta.',
      null => 'No hay conexion con el servidor de nutriflow (${error.error}). '
          'Confirma que este corriendo y que API_BASE_URL apunte a su puerto.',
      _ => '${error.statusCode}: ${error.error}',
    };
  }
}
