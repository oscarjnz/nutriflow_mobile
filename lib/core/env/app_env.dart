import 'package:flutter/foundation.dart';

/// Compile-time config, supplied via `--dart-define-from-file=env.json`
/// (see `env.example.json` at the repo root). Nothing here is a secret - the
/// Supabase anon key and Clerk publishable key are meant to ship in the
/// client; RLS and Clerk's own key scoping are what actually gate access.
/// Never add a service-role or secret key here.
class AppEnv {
  const AppEnv._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const clerkPublishableKey = String.fromEnvironment('CLERK_PUBLISHABLE_KEY');

  /// Base URL of the nutriflow Next.js app's Fase 1 REST endpoints
  /// (src/app/api/*).
  ///
  /// Defaults to the deployed backend, not a dev server. The old default of
  /// `http://localhost:3000` was wrong twice over: from a phone `localhost` is
  /// the phone itself, and this machine's nutriflow instance never ran on 3000
  /// anyway (CLAUDE.md, 2026-07-17). A default that cannot work anywhere is
  /// worse than none.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://nutriflow.dpdns.org',
  );

  static void assertConfigured() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty || clerkPublishableKey.isEmpty) {
      throw StateError(
        'Missing required --dart-define values. Copy env.example.json to '
        'env.json, fill it in, and run with '
        '--dart-define-from-file=env.json.',
      );
    }

    // Release builds no longer ship an Android network security config
    // permitting cleartext, so a plain-HTTP backend fails there as an opaque
    // connection error at the first request. Say what is actually wrong, at
    // startup, instead. Debug builds keep working over HTTP against a local
    // dev server, which is the only case that legitimately needs it.
    if (kReleaseMode && !Uri.parse(apiBaseUrl).isScheme('https')) {
      throw StateError(
        'API_BASE_URL must use https in a release build (got "$apiBaseUrl"). '
        'Cleartext HTTP is blocked outside debug builds.',
      );
    }
  }
}
