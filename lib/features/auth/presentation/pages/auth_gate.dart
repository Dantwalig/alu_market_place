import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import 'login_page.dart';
import 'verify_email_page.dart';

/// Chooses what to show from the auth state: splash, login, verify or the app.
class AuthGate extends StatelessWidget {
  final Widget signedIn;
  const AuthGate({super.key, required this.signedIn});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      // Drop pushed pages (register, reset) when the session changes.
      listenWhen: (p, c) =>
          p.status != c.status || p.needsVerification != c.needsVerification,
      listener: (context, state) =>
          Navigator.of(context).popUntil((r) => r.isFirst),
      buildWhen: (p, c) =>
          p.status != c.status || p.needsVerification != c.needsVerification,
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.unknown:
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          case AuthStatus.unauthenticated:
            return const LoginPage();
          case AuthStatus.authenticated:
            return state.needsVerification ? const VerifyEmailPage() : signedIn;
        }
      },
    );
  }
}
