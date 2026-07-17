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
  /// (src/app/api/*). Defaults to the local dev server.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static void assertConfigured() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty || clerkPublishableKey.isEmpty) {
      throw StateError(
        'Missing required --dart-define values. Copy env.example.json to '
        'env.json, fill it in, and run with '
        '--dart-define-from-file=env.json.',
      );
    }
  }
}
