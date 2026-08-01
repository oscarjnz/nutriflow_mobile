import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/api/providers.dart';
import 'core/auth/clerk_bootstrap.dart';
import 'core/auth/desktop_oauth_redirect.dart';
import 'core/env/app_env.dart';
import 'core/supabase/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppEnv.assertConfigured();

  // Must be started before the auth state: ClerkAuthState.initialize()
  // subscribes to config.deepLinkStream once, at construction.
  final desktopRedirect = await DesktopOAuthRedirect.start();

  final clerkAuth = await bootstrapClerk(desktopRedirect: desktopRedirect);
  await bootstrapSupabase(clerkAuth);

  runApp(
    ProviderScope(
      overrides: [clerkAuthProvider.overrideWithValue(clerkAuth)],
      child: ClerkAuth(
        authState: clerkAuth,
        child: const NutriFlowApp(),
      ),
    ),
  );
}
