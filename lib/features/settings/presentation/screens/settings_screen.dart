import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Ajustes Globales',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(20.0),
            physics: const BouncingScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Personalización',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    initialValue: settings.themeMode,
                    dropdownColor: theme.colorScheme.surfaceContainerHigh,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Tema de la Aplicación',
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'light',
                        child: Text('Modo Claro'),
                      ),
                      DropdownMenuItem(
                        value: 'dark',
                        child: Text('Modo Oscuro'),
                      ),
                      DropdownMenuItem(
                        value: 'system',
                        child: Text('Tema del Sistema'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(settingsNotifierProvider.notifier)
                            .updateThemeMode(value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Notificaciones',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                    width: 1,
                  ),
                ),
                child: SwitchListTile.adaptive(
                  shapeVamos a modernizar el archivo `lib/features/settings/presentation/screens/settings_screen.dart` adaptándolo por completo al sistema de diseño **Material You (M3)**:
- Reemplazo de los `Card` genéricos por contenedores tonales con radios de **24px** y bordes suaves de `outlineVariant`.
- Formateo de los títulos de sección utilizando la jerarquía tipográfica `titleSmall` / `labelLarge` vinculada al `ColorScheme`.
- Estilización de la selección de tema y switches para que encajen perfectamente con la experiencia fluida de M3.

Copia y ejecuta este bloque completo en tu **terminal de VS Code**:

```bash
cat << 'EOF' > lib/features/settings/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Ajustes Globales',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.4,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(20.0),
            physics: const BouncingScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Personalización',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 6.0,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      initialValue: settings.themeMode,
                      dropdownColor: theme.colorScheme.surfaceContainerHigh,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Tema de la Aplicación',
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'light',
                          child: Row(
                            children: [
                              Icon(
                                Icons.light_mode_outlined,
                                size: 20,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              const Text('Modo Claro'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'dark',
                          child: Row(
                            children: [
                              Icon(
                                Icons.dark_mode_outlined,
                                size: 20,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              const Text('Modo Oscuro'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'system',
                          child: Row(
                            children: [
                              Icon(
                                Icons.brightness_auto_outlined,
                                size: 20,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              const Text('Tema del Sistema'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(settingsNotifierProvider.notifier)
                              .updateThemeMode(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Notificaciones',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications_active_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Notificaciones Push',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    'Recibe alertas de trueques y chats',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  value: settings.pushNotificationsEnabled,
                  onChanged: (value) {
                    ref
                        .read(settingsNotifierProvider.notifier)
                        .togglePushNotifications(value);
                  },
                ),
              ),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error al cargar la configuración: $error',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}
