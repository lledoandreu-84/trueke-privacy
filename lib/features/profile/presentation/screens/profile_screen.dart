import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/core/theme/app_colors.dart';
import 'package:trueke/features/auth/providers/auth_provider.dart';
import 'package:trueke/app/routes/app_routes.dart';

class ProfileScreen extends ConsumerWidget {
  final String? userId;

  const ProfileScreen({
    super.key,
    this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.value;

    final userName = user?.userMetadata?['full_name'] ?? user?.email?.split('@').first ?? 'Usuario Trueke';
    final userEmail = user?.email ?? 'correo@ejemplo.com';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mi Cuenta',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 👤 1. Cabecera de Perfil Pro Rediseñada
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.surfaceMint,
                    child: Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMint,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, size: 14, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'Sin valoraciones',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 📦 2. Opciones de Gestión
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.swap_horiz_rounded,
                  title: 'Mis Ofertas de Trueke',
                  subtitle: 'Gestionar intercambios propuestos y recibidos',
                  onTap: () {},
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0), indent: 16, endIndent: 16),
                _buildMenuItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Mis Productos Publicados',
                  subtitle: 'Tienes 1 artículo publicado',
                  onTap: () {},
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0), indent: 16, endIndent: 16),
                _buildMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Historial de Truekes',
                  subtitle: 'Intercambios de bienes y estado financiero',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 🚪 3. Botón de Cerrar Sesión
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.auth, (route) => false);
              }
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
            label: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.redAccent, fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFFEE2E2)),
              backgroundColor: const Color(0xFFFFF5F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceMint,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11.5,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
    );
  }
}
