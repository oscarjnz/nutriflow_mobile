import 'dart:async';
import 'dart:io';

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
  DesktopOAuthRedirect._(this._server, this.redirectUri) {
    unawaited(_serve());
  }

  /// Path we tell Clerk to redirect back to. Anything else hitting the server
  /// is answered with a 404 rather than treated as an auth callback.
  static const _callbackPath = '/clerk-callback';

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
      final uri = Uri.parse('http://127.0.0.1:${server.port}$_callbackPath');
      debugPrint('[oauth] loopback redirect listening on $uri');
      return DesktopOAuthRedirect._(server, uri);
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
        if (uri.path != _callbackPath) {
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
          continue;
        }

        debugPrint('[oauth] callback received: ${uri.path}?${uri.query}');
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.html
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
