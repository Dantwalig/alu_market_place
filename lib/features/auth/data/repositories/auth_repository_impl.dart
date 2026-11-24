import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../domain/entities/app_user.dart';
import '../../../domain/repositories/auth_repository.dart';

/// Firebase-backed implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl();
  final _auth = FirebaseAuth.instance;

  @override
  Stream<AppUser?> get authStateChanges =>
      _auth.authStateChanges().map(_userFromFirebase);

  @override
  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
  }

  @override
  Future<void> registerWithEmail(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    await cred.user?.updateDisplayName(name);
    await cred.user?.sendEmailVerification();
  }

  @override
  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;
    final googleAuth = await googleUser.authentication;
    final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    await _auth.signInWithCredential(cred);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  @override
  Future<AppUser?> reloadUser() async {
    await _auth.currentUser?.reload();
    return _userFromFirebase(_auth.currentUser);
  }

  @override
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  AppUser? _userFromFirebase(User? u) {
    if (u == null) return null;
    return AppUser(
      uid: u.uid,
      email: u.email ?? '',
      displayName: u.displayName,
      emailVerified: u.emailVerified,
    );
  }
}
