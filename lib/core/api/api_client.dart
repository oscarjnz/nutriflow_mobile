import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:dio/dio.dart';

import '../auth/clerk_bootstrap.dart';
import '../env/app_env.dart';

/// Dio instance for the Fase 1 REST endpoints (`nutriflow/src/app/api/*`) -
/// server-side business logic (meal-plan generation, NLP parsing) that must
/// never be reimplemented client-side (CLAUDE.md section 2). Every request
/// carries the current Clerk JWT as `Authorization: Bearer`, matching the
/// `getUser()` check each route handler performs server-side.
Dio buildApiClient(ClerkAuthState clerkAuth) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppEnv.apiBaseUrl,
      contentType: 'application/json',
      // Without these, a hung connection (dev server down, dropped
      // packets) spins forever instead of surfacing an error - see
      // CLAUDE.md 2026-07-17 bitacora. 30s covers the slowest call
      // (nlp/parse's LLM round trip); everything else is much faster.
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await currentClerkToken(clerkAuth);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
}
