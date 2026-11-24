import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/tokens.dart';
import '../../../../core/widgets.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_widgets.dart';

/// Shown to email/password users until they click the link in their inbox.
class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = context.select((AuthBloc b) => b.state.user?.email ?? '');
    final bloc = context.read<AuthBloc>();
    return AuthScaffold(
      title: 'Verify your email',
      showBack: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Icon(Icons.mark_email_unread_outlined, size: 56, color: C.orange),
        const SizedBox(height: 16),
        const Text('Check your inbox',
            style: T.display, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('We sent a verification link to\n$email',
            style: T.bodySlate, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        BusyButton(
          label: "I've verified my email",
          onPressed: () => bloc.add(const AuthVerificationCheckRequested()),
        ),
        const SizedBox(height: 12),
        SecondaryButton('Resend email',
            onPressed: () => bloc.add(const AuthVerificationResendRequested())),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => bloc.add(const AuthLogoutRequested()),
          child: Text('Use a different account',
              style: T.body.copyWith(fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}
