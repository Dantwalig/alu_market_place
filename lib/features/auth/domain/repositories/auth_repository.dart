import '../entities/app_user.dart';

/// Thrown by [AuthRepository] with a message that is safe to show to the user.
class AuthFailure implements Exception {
  final String message;
  const AuthFailure(this.message);
  @override
  String toString() => message;
}

abstract class AuthRepository {
  /// Emits the current user on listen, then on every sign-in / sign-out.
  /// This is what keeps the session alive across app restarts.
  Stream<AppUser?> get authStateChanges;

  Future<void> signInWithEmail(String email, String password);

  Future<void> registerWithEmail(String name, String email, String password);

  Future<void> signInWithGoogle();

  Future<void> sendPasswordReset(String email);

  Future<void> sendVerificationEmail();

  Future<AppUser?> reloadUser();

  Future<void> signOut();
}
