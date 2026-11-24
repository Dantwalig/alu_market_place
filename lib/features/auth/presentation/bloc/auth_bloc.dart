import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Holds all authentication state. UI never talks to Firebase directly.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repo) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>((e, emit) =>
        _run(emit, () => _repo.signInWithEmail(e.email, e.password)));
    on<AuthRegisterRequested>(
      (e, emit) => _run(
          emit, () => _repo.registerWithEmail(e.name, e.email, e.password)),
    );
    on<AuthGoogleRequested>((e, emit) => _run(emit, _repo.signInWithGoogle));
    on<AuthPasswordResetRequested>(
      (e, emit) => _run(
        emit,
        () => _repo.sendPasswordReset(e.email),
        success: 'Password reset email sent. Check your inbox.',
      ),
    );
    on<AuthVerificationResendRequested>(
      (e, emit) => _run(emit, _repo.sendVerificationEmail,
          success: 'Verification email sent.'),
    );
    on<AuthVerificationCheckRequested>(_onVerificationCheck);
    on<AuthLogoutRequested>((e, emit) => _run(emit, _repo.signOut));
  }

  final AuthRepository _repo;

  /// Restores the session and then follows Firebase's auth stream.
  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) {
    return emit.forEach<AppUser?>(
      _repo.authStateChanges,
      onData: (user) => user == null
          ? state.copyWith(
              status: AuthStatus.unauthenticated, clearUser: true, busy: false)
          : state.copyWith(status: AuthStatus.authenticated, user: user),
    );
  }

  Future<void> _onVerificationCheck(
      AuthVerificationCheckRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(busy: true));
    try {
      final user = await _repo.reloadUser();
      if (user != null && user.emailVerified) {
        emit(state.copyWith(
            status: AuthStatus.authenticated, user: user, busy: false));
      } else {
        emit(state.copyWith(
          busy: false,
          message: 'Your email is not verified yet. Open the link we sent you.',
          isError: true,
        ));
      }
    } on AuthFailure catch (e) {
      emit(state.copyWith(busy: false, message: e.message, isError: true));
    }
  }

  /// Shared busy / error handling for every repository call.
  Future<void> _run(
    Emitter<AuthState> emit,
    Future<void> Function() action, {
    String? success,
  }) async {
    emit(state.copyWith(busy: true));
    try {
      await action();
      emit(state.copyWith(busy: false, message: success));
    } on AuthFailure catch (e) {
      emit(state.copyWith(busy: false, message: e.message, isError: true));
    }
  }
}
