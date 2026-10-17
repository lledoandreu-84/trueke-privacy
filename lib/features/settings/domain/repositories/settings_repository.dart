import '../../models/settings_model.dart';

abstract class SettingsRepository {
  /// Carga la configuración de ajustes guardada localmente.
  Future<SettingsModel> loadSettings();

  /// Guarda de forma persistente los ajustes del usuario.
  Future<void> saveSettings(SettingsModel settings);
}
