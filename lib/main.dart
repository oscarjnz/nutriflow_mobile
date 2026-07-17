import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/api/providers.dart';
import 'core/auth/clerk_bootstrap.dart';
import 'core/env/app_env.dart';
import 'core/supabase/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppEnv.assertConfigured();

  final clerkAuth = await bootstrapClerk();
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
