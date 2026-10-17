import 'package:shared_preferences/shared_preferences.dart';
import '../../models/settings_model.dart';
import '../../domain/repositories/settings_repository.dart';

class SharedPrefsSettingsRepository implements SettingsRepository {
  static const String _themeKey = 'settings_theme_mode';
  static const String _notificationsKey = 'settings_push_enabled';

  @override
  Future<SettingsModel> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(_themeKey) ?? 'system';
    final pushEnabled = prefs.getBool(_notificationsKey) ?? true;

    return SettingsModel(
      themeMode: theme,
      pushNotificationsEnabled: pushEnabled,
    );
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, settings.themeMode);
    await prefs.setBool(_notificationsKey, settings.pushNotificationsEnabled);
  }
}
