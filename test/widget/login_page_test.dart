import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alu_market_place/core/utils/validators.dart';
import 'package:alu_market_place/features/auth/domain/entities/app_user.dart';
import 'package:alu_market_place/features/auth/domain/repositories/auth_repository.dart';
import 'package:alu_market_place/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:alu_market_place/features/auth/presentation/pages/login_page.dart';
import 'package:alu_market_place/features/settings/data/repositories/shared_prefs_settings_repository.dart';
import 'package:alu_market_place/features/settings/domain/repositories/settings_repository.dart';
import 'package:alu_market_place/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late AuthBloc authBloc;
  late SettingsCubit settingsCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    mockAuthRepo = MockAuthRepository();
    authBloc = AuthBloc(mockAuthRepo);
    settingsCubit = SettingsCubit(SharedPrefsSettingsRepository(prefs));
  });

  tearDown(() {
    authBloc.close();
    settingsCubit.close();
  });

  Widget buildTestableWidget() => MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
        ],
        child: MaterialApp(home: LoginPage()),
      );

  group('LoginPage', () {
    testWidgets('renders email and password fields and login button',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Log in'), findsNWidgets(2));
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
    });

    testWidgets('shows validation error when submitting empty form',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final loginButton = find.text('Log in').last;
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Validators should show error text on empty fields
      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
    });

    testWidgets('email validator rejects invalid email',
        (WidgetTester tester) async {
      expect(Validators.email(''), 'Enter your email');
      expect(Validators.email('not-an-email'), 'Enter a valid email');
      expect(Validators.email('alice@alu.edu'), null);
    });

    testWidgets('password validator rejects short password',
        (WidgetTester tester) async {
      expect(Validators.requiredPassword(''), 'Enter your password');
      expect(Validators.requiredPassword('12345'),
          'Password must be at least 6 characters');
      expect(Validators.requiredPassword('password123'), null);
    });

    testWidgets('google sign-in button calls signInWithGoogle',
        (WidgetTester tester) async {
      when(() => mockAuthRepo.signInWithGoogle()).thenAnswer((_) async {});
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.text('Continue with Google'));
      await tester.pump();

      verify(() => mockAuthRepo.signInWithGoogle()).called(1);
    });

  });
}
