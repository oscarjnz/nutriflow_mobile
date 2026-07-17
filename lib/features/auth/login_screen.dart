import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';

/// Entry point for signed-out users. Wraps Clerk's own [ClerkAuthentication]
/// panel (sign-in/sign-up, OAuth strategies - whatever is enabled in the
/// Clerk dashboard) rather than hand-rolling auth forms: CLAUDE.md section 2
/// says never reimplement logic the backend/provider already owns, and that
/// applies to auth flows too, not just nutrition math.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ClerkAuthentication(),
          ),
        ),
      ),
    );
  }
}
