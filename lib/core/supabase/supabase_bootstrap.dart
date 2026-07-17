import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/clerk_bootstrap.dart';
import '../env/app_env.dart';

/// Initializes the Supabase client for direct CRUD (meal_logs, weight_logs,
/// favorites, fasting_sessions, foods reads - see CLAUDE.md section 6). The
/// `accessToken` callback is the Clerk -> Supabase Third-Party Auth bridge:
/// every request signs with the current Clerk JWT, and RLS (`app_user_id()`)
/// does the actual per-user filtering - no policy lives on this client.
Future<void> bootstrapSupabase(ClerkAuthState clerkAuth) async {
  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    anonKey: AppEnv.supabaseAnonKey,
    accessToken: () => currentClerkToken(clerkAuth),
  );
}

SupabaseClient get supabase => Supabase.instance.client;
