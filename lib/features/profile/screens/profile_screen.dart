import 'package:trueke/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(titleText: 'Mi Perfil'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Usuario Trueke',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'miembro@trueke.app',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Configuración',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.shield_rounded, color: theme.colorScheme.onSurfaceVariant),
                  title: Text('Seguridad y Privacidad', style: TextStyle(color: theme.colorScheme.onSurface)),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  onTap: () {},
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
                ListTile(
                  leading: Icon(Icons.notifications_rounded, color: theme.colorScheme.onSurfaceVariant),
                  title: Text('Notificaciones', style: TextStyle(color: theme.colorScheme.onSurface)),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  onTap: () {},
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2)),
                ListTile(
                  leading: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
                  title: Text('Cerrar Sesión', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600)),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
