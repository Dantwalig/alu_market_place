import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/tokens.dart';
import '../../../../core/ui/ui_message.dart';
import '../../../../core/widgets.dart';
import '../bloc/auth_bloc.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String initialEmail;
  const ForgotPasswordPage({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void initState() {
    super.initState();
    _email.text = widget.initialEmail;
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthPasswordResetRequested(_email.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Forgot password',
      showBack: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Reset your password', style: T.display),
            const SizedBox(height: 6),
            const Text(
              'We will send a reset link to your email address.',
              style: T.bodySlate,
            ),
            const SizedBox(height: 24),
            AuthTextField(
              label: 'Email',
              controller: _email,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (p, c) =>
                  c.message != null && p.nonce != c.nonce,
              listener: (context, state) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text(state.message!),
                    backgroundColor: state.isError ? C.red : C.green,
                    behavior: SnackBarBehavior.floating,
                  ));
              },
              child: BusyButton(
                label: 'Send reset email',
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
