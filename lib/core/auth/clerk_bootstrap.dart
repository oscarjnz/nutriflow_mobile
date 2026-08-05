import 'package:clerk_flutter/clerk_flutter.dart';

import '../env/app_env.dart';
import 'clerk_localizations_es.dart';
import 'desktop_oauth_redirect.dart';

/// Creates the single [ClerkAuthState] the app runs on. Built once in
/// `main()` (before `runApp`) so the same instance can be handed to both
/// `Supabase.initialize`'s `accessToken` callback and the [ClerkAuth]
/// widget wrapping the app - per CLAUDE.md section 6, the Clerk session
/// token is the one credential shared between direct Supabase CRUD and the
/// Fase 1 REST calls, so there must be exactly one source of truth for it.
///
/// [desktopRedirect], when supplied, switches OAuth from Clerk's in-app
/// WebView to the system browser. That is mandatory on Windows, where the
/// WebView cannot report the OAuth callback at all - see
/// [DesktopOAuthRedirect] for the full explanation. Passing null (mobile)
/// leaves the original, proven in-app flow untouched.
Future<ClerkAuthState> bootstrapClerk({
  DesktopOAuthRedirect? desktopRedirect,
}) {
  final spanish = ClerkSdkLocalizationsEs();
  return ClerkAuthState.create(
    config: ClerkAuthConfig(
      publishableKey: AppEnv.clerkPublishableKey,
      // Clerk picks its copy from the *device* locale
      // (`ClerkAuthState.localizationsOf`), so a phone set to English would
      // otherwise show English inside an app that is Spanish everywhere else.
      // Registering Spanish and nothing else, with Spanish as the fallback,
      // makes the choice unconditional - which is the intent: NutriFlow's UI
      // is Spanish (CLAUDE.md section 5), not "whatever the phone is set to".
      localizations: {'es': spanish},
      fallbackLocalization: spanish,
      // Returning a non-null Uri here is what makes `ssoSignIn` call
      // `launchUrl` instead of showing its WebView dialog. The strategy is
      // ignored: every SSO strategy this app offers needs the same treatment
      // on desktop.
      redirectionGenerator: desktopRedirect == null
          ? null
          : (context, strategy) => desktopRedirect.redirectUri,
      deepLinkStream: desktopRedirect?.deepLinks,
    ),
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
