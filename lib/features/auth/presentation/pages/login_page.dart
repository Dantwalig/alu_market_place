import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_widgets.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// StatefulWidget only to own/dispose the text controllers and form key.
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill the email saved in SharedPreferences (if the user opted in).
    _email.text = context.read<SettingsCubit>().state.rememberedEmail;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<SettingsCubit>().rememberLogin(_email.text);
      context
          .read<AuthBloc>()
          .add(AuthLoginRequested(_email.text, _password.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Log in',
      showBack: false,
      child: Form(
        key: _formKey,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Welcome back', style: T.display),
          const SizedBox(height: 6),
          const Text('Log in to buy and sell with students on campus.',
              style: T.bodySlate),
          const SizedBox(height: 24),
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
            validator: Validators.requiredPassword,
            isPassword: true,
            textInputAction: TextInputAction.done,
          ),
          BlocBuilder<SettingsCubit, AppSettings>(
            buildWhen: (p, c) => p.rememberEmail != c.rememberEmail,
            builder: (context, s) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              title: const Text('Remember my email', style: T.caption),
              value: s.rememberEmail,
              activeColor: C.navy,
              onChanged: (v) =>
                  context.read<SettingsCubit>().setRememberEmail(v ?? false),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      ForgotPasswordPage(initialEmail: _email.text))),
              child: Text('Forgot password?',
                  style: T.caption
                      .copyWith(color: C.navy, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 4),
          BusyButton(label: 'Log in', onPressed: _submit),
          const SizedBox(height: 12),
          const _GoogleButton(),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('New here?', style: T.bodySlate),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterPage())),
              child: Text('Create account',
                  style: T.body.copyWith(fontWeight: FontWeight.w700)),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton();
  @override
  Widget build(BuildContext context) {
    final busy = context.select((AuthBloc b) => b.state.busy);
    return SecondaryButton(
      'Continue with Google',
      onPressed: busy
          ? null
          : () => context.read<AuthBloc>().add(const AuthGoogleRequested()),
    );
  }
}
