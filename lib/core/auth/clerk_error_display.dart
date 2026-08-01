import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';

/// Surfaces [clerk.ClerkError]s to the user and to the debug console.
///
/// This is NOT optional decoration. Without a [ClerkErrorListener] anywhere in
/// the tree, `ClerkAuthState.handleError` falls through to the base
/// `clerk.Auth.handleError`, which is literally `throw error`. Every failed
/// sign-in/sign-up then becomes an exception that `safelyCall` catches and
/// discards (the sign-in panel passes its own `onError` that just clears the
/// form), so the user presses "Continuar" and sees absolutely nothing happen.
/// Clerk's own `ClerkAuth.materialAppBuilder` wires this listener in for the
/// same reason - we install it by hand because `main()` builds the
/// [ClerkAuthState] itself (see core/auth/clerk_bootstrap.dart).
///
/// Must sit BELOW [MaterialApp] so a [ScaffoldMessenger] exists, and below the
/// [ClerkAuth] widget so the error stream can be found. `MaterialApp.builder`
/// is the one spot that satisfies both.
class ClerkErrorDisplay extends StatelessWidget {
  const ClerkErrorDisplay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClerkErrorListener(handler: _handle, child: child);
  }

  static void _handle(BuildContext context, clerk.ClerkError error) {
    // Always log with full context. CLAUDE.md section 9: never silence an
    // error. `argument` carries the verbatim message from Clerk's API, which
    // is the only part that says what actually went wrong.
    debugPrint(
      '[clerk] code=${error.code} message="${error.message}" '
      'argument="${error.argument}"',
    );

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final theme = Theme.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          content: Text(
            _messageFor(error),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onError,
            ),
          ),
        ),
      );
  }

  /// Clerk's own localizations only cover the SDK-internal error codes; the
  /// interesting ones ([clerk.ClerkErrorCode.serverErrorResponse]) carry the
  /// server's English text in `argument`, which we pass through rather than
  /// replacing with a vague generic string that would hide the real cause.
  static String _messageFor(clerk.ClerkError error) {
    return switch (error.code) {
      clerk.ClerkErrorCode.serverErrorResponse =>
        error.argument?.trim().orNull ??
            'El servidor de autenticacion rechazo la solicitud.',
      clerk.ClerkErrorCode.externalError =>
        'No pudimos conectar con el servicio de autenticacion. '
            'Revisa tu conexion e intenta de nuevo.',
      clerk.ClerkErrorCode.passwordMatchError =>
        'Las contrasenas no coinciden.',
      clerk.ClerkErrorCode.noSessionTokenRetrieved ||
      clerk.ClerkErrorCode.noSessionFoundForUser =>
        'Tu sesion expiro. Vuelve a iniciar sesion.',
      _ => error.toString(),
    };
  }
}

extension on String {
  String? get orNull => isEmpty ? null : this;
}
