import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/macro_goal.dart';
import '../local_db/cached_fetch.dart';
import '../local_db/providers.dart';
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
/// direct (CLAUDE.md section 6). Read through the local cache
/// (docs/superpowers/specs/2026-07-30-weight-logs-local-cache-design.md)
/// so the dashboard still shows the last known goal if the request fails.
final goalProvider = FutureProvider<CachedValue<MacroGoal>>((ref) {
  final cache = ref.watch(localCacheProvider);
  return cachedFetch<MacroGoal>(
    cache: cache,
    key: 'goal',
    fetchRaw: () async => (await ref.watch(nutriFlowApiProvider).getGoal()).toJson(),
    decode: (raw) => MacroGoal.fromJson(raw as Map<String, dynamic>),
    onNetworkError: (error, stackTrace) =>
        debugPrint('getGoal failed, falling back to cache: $error\n$stackTrace'),
    onCacheWriteError: (error, stackTrace) =>
        debugPrint('getGoal could not update the cache: $error\n$stackTrace'),
  );
});

/// GET /api/onboarding/status - drives the auth gate (`app/router.dart`).
/// Autodispose + kept outside `goalProvider` since it's only read once per
/// sign-in, not part of the dashboard's data.
final onboardingStatusProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(nutriFlowApiProvider).getOnboardingStatus();
});
