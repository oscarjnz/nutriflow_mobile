import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

/// Loopback HTTP listener that completes Clerk's OAuth flow on desktop.
///
/// ## Why this exists
///
/// On mobile, `ClerkAuthState.ssoSignIn` opens Google's consent page in an
/// in-app WebView and waits for `NavigationDelegate.onNavigationRequest` to
/// report a navigation to `com.clerk.flutter://callback`, which it cancels and
/// turns into a completed sign-in.
///
/// That mechanism cannot work on Windows. The only `webview_flutter` platform
/// implementation available there is `webview_win_floating`, whose native
/// `NavigationStarting` handler deliberately skips the Dart callback whenever
/// `args->get_IsRedirected()` is true or the request is an HTTP POST:
///
/// ```cpp
/// if (m_isNowGoBackForward || isPostMethod == TRUE || isRedirected == TRUE ...) {
///     userInitiated = false;   // -> onNavigationRequest is never called
/// }
/// ```
///
/// The OAuth callback arrives as exactly that: a 302 redirect following the
/// POST of Google's consent form. So `onNavigationRequest` never fires, the
/// dialog Clerk opened never pops, `ssoSignIn` never returns, and the social
/// button stays stuck in its disabled state forever. That is the "the button
/// greys out after pressing Permitir" symptom.
///
/// ## What we do instead
///
/// The standard OAuth-for-native-apps pattern (RFC 8252): hand the flow to the
/// system browser and catch the redirect on a loopback HTTP server. Clerk
/// supports this out of the box - supplying `redirectionGenerator` in
/// [ClerkAuthConfig] makes `ssoSignIn` call `launchUrl` instead of opening its
/// WebView, and it then expects the completed URL to arrive on
/// `deepLinkStream`, which it feeds to `parseDeepLink`.
///
/// This keeps WebView2 entirely off the critical path and reuses the browser
/// session the user is already signed into.
class DesktopOAuthRedirect {
  DesktopOAuthRedirect._(this._server, this.redirectUri, this._callbackPath) {
    unawaited(_serve());
  }

  /// Fixed prefix of the redirect path. The full path also carries a
  /// per-launch random segment - see [_callbackPath].
  static const _callbackPrefix = '/clerk-callback';

  /// The exact path a request must hit to be treated as an auth callback.
  ///
  /// `$_callbackPrefix/<128 bits of CSPRNG>`, regenerated every launch. Without
  /// the random segment the callback URL is fully predictable: the path is a
  /// constant and the port space is only 16 bits, so any other local process
  /// could sweep loopback in well under a second and POST its own
  /// `rotating_token_nonce` to us. We would hand that to Clerk's
  /// `parseDeepLink` and the user would be signed in to the *attacker's*
  /// account - textbook OAuth login-CSRF, which is exactly what RFC 8252
  /// section 8.9 asks for a `state`-equivalent to prevent.
  ///
  /// The secret lives in the path rather than a query parameter on purpose:
  /// the path survives the round trip through Clerk untouched, whereas extra
  /// query parameters are not guaranteed to be echoed back.
  final String _callbackPath;

  final HttpServer _server;

  /// The URL handed to Clerk as the OAuth redirect target.
  ///
  /// Uses the literal `127.0.0.1` rather than `localhost`: on Windows
  /// `localhost` can resolve to `::1` first, which would miss a server bound
  /// to the IPv4 loopback.
  final Uri redirectUri;

  final _links = StreamController<Uri?>.broadcast();

  /// Deep links captured from the browser, for [ClerkAuthConfig.deepLinkStream].
  Stream<Uri?> get deepLinks => _links.stream;

  /// Starts the listener, or returns null on platforms that do not need it
  /// (mobile keeps Clerk's in-app WebView flow, which is already proven there)
  /// or if the port cannot be bound.
  static Future<DesktopOAuthRedirect?> start() async {
    if (kIsWeb) return null;
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      return null;
    }

    try {
      // Port 0 lets the OS pick a free port. Clerk validates the redirect
      // parameter but does not require the port to be pre-registered on a
      // development instance, so an ephemeral port is fine.
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final secret = base64Url.encode(
        List<int>.generate(16, (_) => Random.secure().nextInt(256)),
      );
      final path = '$_callbackPrefix/$secret';
      final uri = Uri.parse('http://127.0.0.1:${server.port}$path');
      // Port only: the path now carries a secret and must not be logged.
      debugPrint('[oauth] loopback redirect listening on port ${server.port}');
      return DesktopOAuthRedirect._(server, uri, path);
    } on SocketException catch (error) {
      // Not fatal: sign-in with email still works, and we must not stop the
      // app from starting. Logged rather than swallowed (CLAUDE.md section 9).
      debugPrint('[oauth] could not bind loopback redirect server: $error');
      return null;
    }
  }

  Future<void> _serve() async {
    await for (final request in _server) {
      final uri = request.requestedUri;
      try {
        // Both checks matter: the secret segment stops another local process
        // from injecting a callback, and restricting to GET stops a form POST
        // from a page the user happens to have open from reaching us.
        if (uri.path != _callbackPath || request.method != 'GET') {
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
          continue;
        }

        // Neither the query nor the path: the query carries Clerk's handshake
        // token and the path carries our callback secret, and debugPrint still
        // writes to the log in release builds. Parameter names are enough to
        // diagnose a malformed callback.
        debugPrint('[oauth] callback received, params=${uri.queryParameters.keys.toList()}');
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.html
          // The requested URL contains the handshake token, so the browser
          // must not keep this page in history-restorable cache.
          ..headers.set(HttpHeaders.cacheControlHeader, 'no-store')
          ..write(_successPage);
        await request.response.close();

        // Emit only after the browser has its page, so the user sees the
        // confirmation even if completing the sign-in takes a moment.
        _links.add(uri);
      } catch (error, stackTrace) {
        debugPrint('[oauth] failed to handle callback: $error\n$stackTrace');
      }
    }
  }

  /// Deliberately not called on a completed sign-in: the listener has to
  /// outlive a single attempt, because the user can sign out and back in, or
  /// abandon the consent screen and retry, and `redirectionGenerator` is
  /// wired once at startup with a fixed [redirectUri]. Tearing down per
  /// attempt would mean re-plumbing that on every retry.
  ///
  /// The exposure that would normally argue for a short lifetime is closed by
  /// the secret in [_callbackPath] instead. Kept for tests and for an explicit
  /// shutdown path if the app ever grows one.
  @visibleForTesting
  Future<void> dispose() async {
    await _links.close();
    await _server.close(force: true);
  }

  static const _successPage = '''
<!doctype html>
<html lang="es">
  <head>
    <meta charset="utf-8" />
    <title>NutriFlow</title>
    <style>
      body {
        margin: 0;
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #fdfdfc;
        color: #2c2720;
        font-family: "Plus Jakarta Sans", "Segoe UI", system-ui, sans-serif;
      }
      .card {
        max-width: 26rem;
        padding: 2.5rem;
        border-radius: 1.5rem;
        background: #ffffff;
        border: 1px solid #e6e2db;
        box-shadow: 0 18px 40px -24px rgba(44, 39, 32, 0.45);
        text-align: center;
      }
      h1 { font-size: 1.25rem; margin: 0 0 0.75rem; color: #668b4b; }
      p { margin: 0; line-height: 1.6; color: #766d60; }
    </style>
  </head>
  <body>
    <div class="card">
      <h1>Listo, ya iniciaste sesion</h1>
      <p>Puedes cerrar esta pestana y volver a NutriFlow.</p>
    </div>
  </body>
</html>
''';
}
