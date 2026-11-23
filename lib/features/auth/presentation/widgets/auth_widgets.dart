import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/tokens.dart';
import '../bloc/auth_bloc.dart';

/// Visibility lives in a ValueNotifier, so no setState is needed.
class AuthTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isPassword;
  final TextInputAction? textInputAction;
  final ValueNotifier<bool>? obscure;

  AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.isPassword = false,
    this.textInputAction,
  }) : obscure = isPassword ? ValueNotifier<bool>(true) : null;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: T.fieldLabel),
      const SizedBox(height: 6),
      ValueListenableBuilder<bool>(
        valueListenable: obscure ?? ValueNotifier<bool>(false),
        builder: (context, hidden, _) => TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: isPassword && hidden,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: T.body,
          decoration: InputDecoration(
            filled: true,
            fillColor: C.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: _border(C.inputBorder),
            enabledBorder: _border(C.inputBorder),
            focusedBorder: _border(C.navy),
            errorBorder: _border(C.red),
            focusedErrorBorder: _border(C.red),
            errorStyle: T.caption.copyWith(color: C.red),
            suffixIcon: isPassword
                ? IconButton(
                    tooltip: hidden ? 'Show password' : 'Hide password',
                    icon: Icon(hidden ? Icons.visibility_off : Icons.visibility,
                        color: C.slate),
                    onPressed: () => obscure!.value = !hidden,
                  )
                : null,
          ),
        ),
      ),
    ]);
  }

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c));
}

class AuthMessageListener extends StatelessWidget {
  final Widget child;
  const AuthMessageListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) => c.message != null && p.nonce != c.nonce,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(state.message!),
            backgroundColor: state.isError ? C.red : C.green,
            behavior: SnackBarBehavior.floating,
          ));
      },
      child: child,
    );
  }
}

class BusyButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const BusyButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final busy = context.select((AuthBloc b) => b.state.busy);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: C.navy,
          foregroundColor: C.white,
          disabledBackgroundColor: C.border,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child:
                    CircularProgressIndicator(strokeWidth: 2.5, color: C.navy),
              )
            : Text(label, style: T.label.copyWith(color: C.white)),
      ),
    );
  }
}

/// Scrollable, centred, width-limited body so pages survive landscape mode.
class AuthScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showBack;
  const AuthScaffold(
      {super.key,
      required this.title,
      required this.child,
      this.showBack = true});

  @override
  Widget build(BuildContext context) {
    return AuthMessageListener(
      child: Scaffold(
        appBar: AppBar(title: Text(title), automaticallyImplyLeading: showBack),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: child),
            ),
          ),
        ),
      ),
    );
  }
}
