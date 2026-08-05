import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/clerk_bootstrap.dart';
import '../env/app_env.dart';
import 'supabase_role_claim.dart';

/// Initializes the Supabase client for direct CRUD (meal_logs, weight_logs,
/// favorites, fasting_sessions, foods reads - see CLAUDE.md section 6). The
/// `accessToken` callback is the Clerk -> Supabase Third-Party Auth bridge:
/// every request signs with the current Clerk JWT, and RLS (`app_user_id()`)
/// does the actual per-user filtering - no policy lives on this client.
Future<void> bootstrapSupabase(ClerkAuthState clerkAuth) async {
  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
    accessToken: () async {
      final jwt = await currentClerkToken(clerkAuth);
      if (jwt == null) return null;
      // A token without `"role": "authenticated"` is not rejected by
      // PostgREST - it is downgraded to `anon`, and since every policy here
      // is granted TO authenticated, reads come back empty with HTTP 200.
      // Failing loudly is the only way that stays visible; see
      // [jwtCarriesAuthenticatedRole] for how that silence cost a session.
      if (!jwtCarriesAuthenticatedRole(jwt)) {
        throw StateError(
          'El token de Clerk no trae el claim "role": "authenticated", asi que '
          'Supabase lo trataria como visitante anonimo y toda consulta '
          'volveria vacia. Agrega ese claim en Clerk Dashboard > Sessions > '
          'Customize session token, en la instancia de produccion.',
        );
      }
      return jwt;
    },
  );
}

SupabaseClient get supabase => Supabase.instance.client;
