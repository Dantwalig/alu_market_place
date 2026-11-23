import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SharedPrefsSettingsRepository implements SettingsRepository {
  SharedPrefsSettingsRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _kTextSize = 'text_size';
  static const _kUnreadBadge = 'show_unread_badge';
  static const _kRememberEmail = 'remember_email';
  static const _kSavedEmail = 'saved_email';

  @override
  AppSettings load() {
    final sizeName = _prefs.getString(_kTextSize);
    return AppSettings(
      textSize: TextSize.values
          .firstWhere((t) => t.name == sizeName, orElse: () => TextSize.normal),
      showUnreadBadge: _prefs.getBool(_kUnreadBadge) ?? true,
      rememberEmail: _prefs.getBool(_kRememberEmail) ?? false,
      savedEmail: _prefs.getString(_kSavedEmail) ?? '',
    );
  }

  @override
  Future<void> save(AppSettings s) async {
    await _prefs.setString(_kTextSize, s.textSize.name);
    await _prefs.setBool(_kUnreadBadge, s.showUnreadBadge);
    await _prefs.setBool(_kRememberEmail, s.rememberEmail);
    await _prefs.setString(_kSavedEmail, s.savedEmail);
  }
}
