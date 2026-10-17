import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/shared_prefs_settings_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../models/settings_model.dart';

// Provider base para el repositorio de ajustes
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SharedPrefsSettingsRepository();
});

// Notifier asíncrono para gestionar de forma reactiva las preferencias globales
class SettingsNotifier extends AsyncNotifier<SettingsModel> {
  @override
  Future<SettingsModel> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.loadSettings();
  }

  /// Actualiza el modo de tema de forma reactiva y persistente
  Future<void> updateThemeMode(String themeMode) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
    state = AsyncData(updatedSettings);

    try {
      final repository = ref.read(settingsRepositoryProvider);
      await repository.saveSettings(updatedSettings);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      ref.invalidateSelf();
    }
  }

  /// Alterna el estado de las notificaciones push de forma reactiva y persistente
  Future<void> togglePushNotifications(bool enabled) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final updatedSettings = currentSettings.copyWith(
      pushNotificationsEnabled: enabled,
    );
    state = AsyncData(updatedSettings);

    try {
      final repository = ref.read(settingsRepositoryProvider);
      await repository.saveSettings(updatedSettings);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      ref.invalidateSelf();
    }
  }
}

// Provider global de la configuración de ajustes de la aplicación
final settingsNotifierProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsModel>(
      SettingsNotifier.new,
    );
