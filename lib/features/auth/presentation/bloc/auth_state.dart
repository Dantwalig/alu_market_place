part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final AppUser? user;

  final bool busy;

  /// One-shot message for a snackbar. [nonce] changes whenever a new message
  /// is set so identical consecutive messages are still shown.
  final String? message;
  final bool isError;
  final int nonce;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.busy = false,
    this.message,
    this.isError = false,
    this.nonce = 0,
  });

  /// True for a signed-in email/password user who has not verified yet.
  bool get needsVerification =>
      status == AuthStatus.authenticated &&
      user != null &&
      !user!.emailVerified;

  /// Copies the state. [message] is cleared unless provided again.
  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool clearUser = false,
    bool? busy,
    String? message,
    bool isError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      busy: busy ?? this.busy,
      message: message,
      isError: isError,
      nonce: message != null ? nonce + 1 : nonce,
    );
  }

  @override
  List<Object?> get props => [status, user, busy, message, isError, nonce];
}
