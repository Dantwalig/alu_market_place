import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/tokens.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context
          .read<AuthBloc>()
          .add(AuthRegisterRequested(_name.text, _email.text, _password.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create account',
      child: Form(
        key: _formKey,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Join ALU Market', style: T.display),
          const SizedBox(height: 6),
          const Text("We'll email you a link to verify your address.",
              style: T.bodySlate),
          const SizedBox(height: 24),
          AuthTextField(
            label: 'Full name',
            controller: _name,
            validator: Validators.name,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Email',
            controller: _email,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Password',
            controller: _password,
            validator: Validators.newPassword,
            isPassword: true,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Confirm password',
            controller: _confirm,
            validator: (v) => Validators.confirmPassword(v, _password.text),
            isPassword: true,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 24),
          BusyButton(label: 'Create account', onPressed: _submit),
        ]),
      ),
    );
  }
}
