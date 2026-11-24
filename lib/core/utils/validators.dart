/// Form field validators used by the auth screens.
///
/// Each validator returns `null` when the input is valid, or a user-facing
/// error message when it is not.
String? email(String? value) {
  if (value == null || value.trim().isEmpty) return 'Enter your email';
  final emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  if (!emailRegExp.hasMatch(value.trim())) return 'Enter a valid email';
  return null;
}

String? requiredPassword(String? value) {
  if (value == null || value.isEmpty) return 'Enter your password';
  if (value.length < 6) return 'Password must be at least 6 characters';
  return null;
}

String? required(String? value, {String label = 'This field'}) {
  if (value == null || value.trim().isEmpty) return '$label is required';
  return null;
}
