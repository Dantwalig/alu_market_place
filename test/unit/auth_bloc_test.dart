import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:alu_market_place/features/auth/domain/entities/app_user.dart';
import 'package:alu_market_place/features/auth/domain/repositories/auth_repository.dart';
import 'package:alu_market_place/features/auth/presentation/bloc/auth_bloc.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
  });

  final user = AppUser(
    uid: 'U1',
    email: 'alice@alu.edu',
    displayName: 'Alice',
    emailVerified: true,
  );

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated when auth state has a user',
      build: () {
        when(() => repo.authStateChanges).thenAnswer(
          (_) => Stream.value(user),
        );
        return AuthBloc(repo);
      },
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [
        AuthState(
          status: AuthStatus.authenticated,
          user: user,
          busy: false,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated when auth state is null',
      build: () {
        when(() => repo.authStateChanges).thenAnswer((_) => Stream.value(null));
        return AuthBloc(repo);
      },
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [
        AuthState(
          status: AuthStatus.unauthenticated,
          busy: false,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'login requested sets busy then clears busy on success',
      build: () {
        when(() => repo.signInWithEmail('alice@alu.edu', 'password123'))
            .thenAnswer((_) async => null);
        return AuthBloc(repo);
      },
      act: (bloc) =>
          bloc.add(AuthLoginRequested('alice@alu.edu', 'password123')),
      expect: () => [
        const AuthState(busy: true),
        AuthState(busy: false, message: null),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'login failure emits AuthFailure message and clears busy',
      build: () {
        when(() => repo.signInWithEmail('bad@alu.edu', 'wrong'))
            .thenThrow(const AuthFailure('Invalid email or password.'));
        return AuthBloc(repo);
      },
      act: (bloc) => bloc.add(const AuthLoginRequested('bad@alu.edu', 'wrong')),
      expect: () => [
        const AuthState(busy: true),
        AuthState(
          busy: false,
          message: 'Invalid email or password.',
          isError: true,
          nonce: 1,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'register requested sets busy then clears busy',
      build: () {
        when(() =>
                repo.registerWithEmail('Alice', 'alice@alu.edu', 'password123'))
            .thenAnswer((_) async => null);
        return AuthBloc(repo);
      },
      act: (bloc) => bloc.add(const AuthRegisterRequested(
        'Alice',
        'alice@alu.edu',
        'password123',
      )),
      expect: () => [
        const AuthState(busy: true),
        AuthState(busy: false, message: null),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'google sign-in requested sets busy then clears busy',
      build: () {
        when(() => repo.signInWithGoogle()).thenAnswer((_) async => null);
        return AuthBloc(repo);
      },
      act: (bloc) => bloc.add(const AuthGoogleRequested()),
      expect: () => [
        const AuthState(busy: true),
        AuthState(busy: false, message: null),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'password reset requested emits success message',
      build: () {
        when(() => repo.sendPasswordReset('alice@alu.edu'))
            .thenAnswer((_) async => null);
        return AuthBloc(repo);
      },
      act: (bloc) =>
          bloc.add(const AuthPasswordResetRequested('alice@alu.edu')),
      expect: () => [
        const AuthState(busy: true),
        AuthState(
          busy: false,
          message: 'Password reset email sent. Check your inbox.',
          nonce: 1,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'verification resend requested emits success message',
      build: () {
        when(() => repo.sendVerificationEmail()).thenAnswer((_) async => null);
        return AuthBloc(repo);
      },
      act: (bloc) => bloc.add(const AuthVerificationResendRequested()),
      expect: () => [
        const AuthState(busy: true),
        AuthState(busy: false, message: 'Verification email sent.', nonce: 1),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'logout requested sets busy then unauthenticated',
      build: () {
        when(() => repo.signOut()).thenAnswer((_) async => null);
        when(() => repo.authStateChanges).thenAnswer((_) => Stream.value(null));
        return AuthBloc(repo);
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        const AuthState(busy: true),
        AuthState(busy: false),
      ],
    );
  });
}
