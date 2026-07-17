import 'package:clerk_flutter/clerk_flutter.dart';

import '../env/app_env.dart';

/// Creates the single [ClerkAuthState] the app runs on. Built once in
/// `main()` (before `runApp`) so the same instance can be handed to both
/// `Supabase.initialize`'s `accessToken` callback and the [ClerkAuth]
/// widget wrapping the app - per CLAUDE.md section 6, the Clerk session
/// token is the one credential shared between direct Supabase CRUD and the
/// Fase 1 REST calls, so there must be exactly one source of truth for it.
Future<ClerkAuthState> bootstrapClerk() {
  return ClerkAuthState.create(
    config: ClerkAuthConfig(publishableKey: AppEnv.clerkPublishableKey),
  );
}

/// Current Clerk session JWT, refreshed on every call. Used by both the
/// Supabase `accessToken` callback and the REST API client's auth
/// interceptor - see core/supabase/supabase_bootstrap.dart and
/// core/api/api_client.dart. Returns null when signed out - `Auth.sessionToken`
/// throws a [ClerkError] in that case rather than returning null itself.
Future<String?> currentClerkToken(ClerkAuthState auth) async {
  if (!auth.isSignedIn) return null;
  final token = await auth.sessionToken();
  return token.jwt;
}
