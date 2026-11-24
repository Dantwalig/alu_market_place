import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:alu_market_place/features/settings/domain/entities/app_settings.dart';
import 'package:alu_market_place/features/settings/domain/repositories/settings_repository.dart';
import 'package:alu_market_place/features/settings/presentation/cubit/settings_cubit.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository repo;

  setUp(() {
    repo = MockSettingsRepository();
  });

  group('SettingsCubit', () {
    test('initial state is loaded from repository', () {
      when(() => repo.load())
          .thenReturn(const AppSettings(textSize: TextSize.large));
      final cubit = SettingsCubit(repo);
      expect(cubit.state.textSize, TextSize.large);
      cubit.close();
    });

    test('setTextSize emits and saves the new size', () async {
      when(() => repo.load())
          .thenReturn(const AppSettings(textSize: TextSize.normal));
      when(() => repo.save(any())).thenAnswer((_) async => null);
      final cubit = SettingsCubit(repo);

      await cubit.setTextSize(TextSize.large);

      expect(cubit.state.textSize, TextSize.large);
      verify(() => repo.save(cubit.state)).called(1);
      cubit.close();
    });

    test('setShowUnreadBadge toggles the badge', () async {
      when(() => repo.load()).thenReturn(const AppSettings());
      when(() => repo.save(any())).thenAnswer((_) async => null);
      final cubit = SettingsCubit(repo);

      expect(cubit.state.showUnreadBadge, true);
      await cubit.setShowUnreadBadge(false);
      expect(cubit.state.showUnreadBadge, false);

      await cubit.setShowUnreadBadge(true);
      expect(cubit.state.showUnreadBadge, true);
      cubit.close();
    });

    test('setRememberEmail(false) clears saved email', () async {
      when(() => repo.load()).thenReturn(const AppSettings(
        rememberEmail: true,
        savedEmail: 'alice@alu.edu',
      ));
      when(() => repo.save(any())).thenAnswer((_) async => null);
      final cubit = SettingsCubit(repo);

      expect(cubit.state.rememberEmail, true);
      await cubit.setRememberEmail(false);
      expect(cubit.state.rememberEmail, false);
      expect(cubit.state.savedEmail, '');
      cubit.close();
    });

    test('rememberLogin saves email only when opted in', () async {
      when(() => repo.load())
          .thenReturn(const AppSettings(rememberEmail: true));
      when(() => repo.save(any())).thenAnswer((_) async => null);
      final cubit = SettingsCubit(repo);

      await cubit.rememberLogin('alice@alu.edu');
      expect(cubit.state.savedEmail, 'alice@alu.edu');
      cubit.close();
    });

    test('rememberLogin does nothing when not opted in', () async {
      when(() => repo.load())
          .thenReturn(const AppSettings(rememberEmail: false));
      when(() => repo.save(any())).thenAnswer((_) async => null);
      final cubit = SettingsCubit(repo);

      await cubit.rememberLogin('alice@alu.edu');
      expect(cubit.state.savedEmail, '');
      cubit.close();
    });

    test('resetToDefaults restores default settings', () async {
      when(() => repo.load())
          .thenReturn(const AppSettings(textSize: TextSize.large));
      when(() => repo.save(any())).thenAnswer((_) async => null);
      final cubit = SettingsCubit(repo);

      expect(cubit.state.textSize, TextSize.large);
      await cubit.resetToDefaults();
      expect(cubit.state, const AppSettings());
      cubit.close();
    });
  });
}
