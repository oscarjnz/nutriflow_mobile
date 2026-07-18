import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/macro_goal.dart';
import 'api_client.dart';
import 'nutriflow_api.dart';

/// Set once in main() after ClerkAuthState is created, before runApp -
/// every other provider that needs auth or the API client reads through
/// this rather than each constructing its own ClerkAuthState.
final clerkAuthProvider = Provider<ClerkAuthState>((ref) {
  throw UnimplementedError('clerkAuthProvider must be overridden in main()');
});

final nutriFlowApiProvider = Provider<NutriFlowApi>((ref) {
  final clerkAuth = ref.watch(clerkAuthProvider);
  return NutriFlowApi(buildApiClient(clerkAuth));
});

/// GET /api/goals - server-side logic (falls back to a default when the
/// user has none), so this goes through the REST client, not Supabase
/// direct (CLAUDE.md section 6).
final goalProvider = FutureProvider<MacroGoal>((ref) {
  return ref.watch(nutriFlowApiProvider).getGoal();
});

/// GET /api/onboarding/status - drives the auth gate (`app/router.dart`).
/// Autodispose + kept outside `goalProvider` since it's only read once per
/// sign-in, not part of the dashboard's data.
final onboardingStatusProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(nutriFlowApiProvider).getOnboardingStatus();
});
