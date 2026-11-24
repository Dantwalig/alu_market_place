import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _google = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  AppUser? _map(User? u) => u == null
      ? null
      : AppUser(
          uid: u.uid,
          email: u.email ?? '',
          displayName: u.displayName,
          // Google accounts arrive verified; email/password ones must verify.
          emailVerified: u.emailVerified,
        );

  @override
  Stream<AppUser?> get authStateChanges => _auth.authStateChanges().map(_map);

  @override
  Future<void> signInWithEmail(String email, String password) =>
      _guard(() => _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password));

  @override
  Future<void> registerWithEmail(String name, String email, String password) =>
      _guard(() async {
        final cred = await _auth.createUserWithEmailAndPassword(
            email: email.trim(), password: password);
        await cred.user?.updateDisplayName(name.trim());
        await cred.user?.sendEmailVerification();
      });

  @override
  Future<void> signInWithGoogle() => _guard(() async {
        if (kIsWeb) {
          // The google_sign_in plugin is unreliable in the browser, so the web
          // build uses Firebase's own popup flow instead.
          await _auth.signInWithPopup(GoogleAuthProvider());
          return;
        }
        final account = await _google.signIn();
        if (account == null) {
          throw const AuthFailure('Google sign-in was cancelled.');
        }
        final tokens = await account.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: tokens.accessToken,
          idToken: tokens.idToken,
        );
        await _auth.signInWithCredential(credential);
      });

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> sendVerificationEmail() =>
      _guard(() async => _auth.currentUser?.sendEmailVerification());

  @override
  Future<AppUser?> reloadUser() async {
    await _auth.currentUser?.reload();
    // Refresh the ID token so Firestore rules see the new email_verified claim.
    await _auth.currentUser?.getIdToken(true);
    return _map(_auth.currentUser);
  }

  @override
  Future<void> signOut() async {
    // Sign out of Google too, so the account picker shows again next time.
    if (!kIsWeb) {
      try {
        await _google.signOut();
      } catch (_) {}
    }
    await _auth.signOut();
  }

  /// Runs [action] and converts Firebase errors into friendly [AuthFailure]s.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on AuthFailure {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageFor(e.code));
    } catch (_) {
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }

  static String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Google sign-in was cancelled.';
      case 'popup-blocked':
        return 'The sign-in popup was blocked. Allow popups for this site.';
      case 'account-exists-with-different-credential':
        return 'This email is already registered with a different sign-in method.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
