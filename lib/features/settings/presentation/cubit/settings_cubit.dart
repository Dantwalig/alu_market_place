import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// Holds the user's preferences. Every change is applied immediately and
/// written to SharedPreferences; the saved values are loaded at app start.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._repo) : super(_repo.load());
  final SettingsRepository _repo;

  Future<void> _update(AppSettings next) async {
    emit(next);
    await _repo.save(next);
  }

  Future<void> setTextSize(TextSize size) =>
      _update(state.copyWith(textSize: size));
  Future<void> setShowUnreadBadge(bool v) =>
      _update(state.copyWith(showUnreadBadge: v));

  /// Turning it off also forgets the stored address.
  Future<void> setRememberEmail(bool v) => _update(
      state.copyWith(rememberEmail: v, savedEmail: v ? state.savedEmail : ''));

  /// Called on login: stores the email only if the user opted in.
  Future<void> rememberLogin(String email) async {
    if (state.rememberEmail && state.savedEmail != email.trim()) {
      await _update(state.copyWith(savedEmail: email.trim()));
    }
  }

  Future<void> resetToDefaults() => _update(const AppSettings());
}
