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
  DesktopOAuthRedirect._(this._server, this.redirectUri, this._secret) {
    unawaited(_serve());
  }

  /// The exact path a callback must hit. Fixed, and so is the port, because
  /// Clerk matches an authorized redirect URL on scheme, host, port and path
  /// **exactly** - verified against the production instance on 2026-08-05,
  /// where `com.clerk.flutter://callback/algo` is rejected while
  /// `com.clerk.flutter://callback` is accepted. An ephemeral port or a
  /// random path segment therefore cannot be authorized at all: the URL would
  /// differ on every launch. Every port in [_candidatePorts] must be
  /// registered on the instance (see the note on that list).
  static const _callbackPath = '/clerk-callback';

  /// Name of the query parameter carrying [_secret]. Clerk ignores the query
  /// string when matching authorized redirect URLs (same verification), which
  /// is what lets the secret live here now that the path has to be fixed.
  static const _secretParam = 'nf';

  /// Ports tried in order. All of them are authorized on the Clerk instance,
  /// so binding any one of them works; the list exists only so that another
  /// process already holding the first port does not break sign-in. Chosen
  /// from the dynamic/private range, where a fixed service is unlikely to sit.
  ///
  /// **Adding a port here means nothing until it is also authorized on the
  /// Clerk instance**, or sign-in fails with `resource_missmatch`.
  static const _candidatePorts = [49731, 49732, 49733];

  /// How long a callback stays acceptable after a sign-in attempt starts.
  /// Long enough to pick an account and approve consent, short enough that the
  /// window is closed almost all of the time.
  static const _attemptWindow = Duration(minutes: 10);

  /// 128 bits of CSPRNG, regenerated every launch, sent as [_secretParam] and
  /// required back on the callback.
  ///
  /// Without it the callback URL is fully predictable - fixed port, fixed path
  /// - so any other local process could POST its own `rotating_token_nonce` to
  /// us, we would hand it to Clerk's `parseDeepLink`, and the user would be
  /// signed in to the *attacker's* account. That is textbook OAuth login-CSRF,
  /// the thing RFC 8252 section 8.9 asks for a `state`-equivalent to prevent.
  ///
  /// It used to live in the path, which guaranteed it survived the round trip.
  /// It cannot anymore, for the exact-match reason above. Whether Clerk echoes
  /// an unknown query parameter back has not been verified end to end, so the
  /// secret is checked *when present* and [_attemptStartedAt] carries the
  /// guarantee that does not depend on it.
  final String _secret;

  /// When the current sign-in attempt began, or null if none is in flight.
  ///
  /// A callback is only accepted inside [_attemptWindow] after the user
  /// actually started signing in. This is the half of the defence that holds
  /// even if the secret does not come back: an attacker has to land inside
  /// that window rather than at any moment of the app's lifetime.
  DateTime? _attemptStartedAt;

  final HttpServer _server;

  /// The URL handed to Clerk as the OAuth redirect target. Prefer
  /// [beginAttempt] over reading this directly - see there.
  ///
  /// Uses the literal `127.0.0.1` rather than `localhost`: on Windows
  /// `localhost` can resolve to `::1` first, which would miss a server bound
  /// to the IPv4 loopback. The two are also different origins to Clerk, so
  /// only the authorized one works.
  final Uri redirectUri;

  /// Opens the acceptance window and returns the redirect URL to hand Clerk.
  ///
  /// Call this from `ClerkAuthConfig.redirectionGenerator`, which Clerk
  /// invokes exactly when a sign-in attempt starts - the moment that makes a
  /// callback legitimate.
  Uri beginAttempt() {
    _attemptStartedAt = DateTime.now();
    return redirectUri;
  }

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

    // An OS-assigned port cannot be used: Clerk only redirects to a URL
    // authorized ahead of time, port included. Each candidate is tried in
    // turn so that one busy port is an inconvenience rather than a failure.
    SocketException? lastError;
    for (final port in _candidatePorts) {
      try {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
        final secret = base64Url.encode(
          List<int>.generate(16, (_) => Random.secure().nextInt(256)),
        );
        final uri = Uri.parse(
          'http://127.0.0.1:$port$_callbackPath'
          '?$_secretParam=${Uri.encodeQueryComponent(secret)}',
        );
        // Port only: the URL carries a secret and must not be logged.
        debugPrint('[oauth] loopback redirect listening on port $port');
        return DesktopOAuthRedirect._(server, uri, secret);
      } on SocketException catch (error) {
        lastError = error;
      }
    }

    // Not fatal: sign-in with email still works, and we must not stop the app
    // from starting. Logged rather than swallowed (CLAUDE.md section 9).
    debugPrint(
      '[oauth] could not bind any authorized loopback port '
      '($_candidatePorts): $lastError',
    );
    return null;
  }

  Future<void> _serve() async {
    await for (final request in _server) {
      final uri = request.requestedUri;
      try {
        if (uri.path != _callbackPath || request.method != 'GET') {
          // GET-only stops a form POST from a page the user happens to have
          // open from reaching us at all.
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
          continue;
        }

        if (!_isAcceptableCallback(uri)) {
          request.response.statusCode = HttpStatus.forbidden;
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

  /// Whether a request on the callback path is a genuine reply to a sign-in
  /// this app started, rather than another local process talking to us.
  ///
  /// Two independent checks, because neither is sufficient alone here:
  ///
  /// * The attempt window. A callback outside it cannot correspond to
  ///   anything the user started, and this holds whether or not the secret
  ///   survives the round trip through Clerk.
  /// * The secret, **when it comes back**. It is not required outright only
  ///   because Clerk echoing an unknown query parameter is unverified; a
  ///   *wrong* value is always rejected, and a missing one is logged so the
  ///   round-trip behaviour becomes an observed fact rather than a guess.
  bool _isAcceptableCallback(Uri uri) {
    final startedAt = _attemptStartedAt;
    if (startedAt == null || DateTime.now().difference(startedAt) > _attemptWindow) {
      debugPrint('[oauth] callback rejected: no sign-in attempt in flight');
      return false;
    }

    final presented = uri.queryParameters[_secretParam];
    if (presented == null) {
      debugPrint(
        '[oauth] callback carried no $_secretParam parameter - Clerk did not '
        'echo it back. Accepted on the attempt window alone; see '
        'DesktopOAuthRedirect._secret.',
      );
      return true;
    }
    if (presented != _secret) {
      debugPrint('[oauth] callback rejected: $_secretParam did not match');
      return false;
    }

    // One callback per attempt: a replay cannot ride the same open window.
    _attemptStartedAt = null;
    return true;
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
