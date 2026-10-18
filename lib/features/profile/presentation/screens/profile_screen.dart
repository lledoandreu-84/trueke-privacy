import "../../../auth/providers/auth_provider.dart";
import 'package:trueke/features/products/providers/products_provider.dart';
import 'package:trueke/features/truekes/presentation/screens/truekes_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/offers/presentation/screens/trade_offers_screen.dart';
import 'package:trueke/features/profile/providers/profile_provider.dart';
import 'package:trueke/features/reviews/providers/reviews_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'my_published_products_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.border,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider(widget.userId));
    final liveRatingAsync = ref.watch(userRatingAverageProvider(widget.userId));
    final myProductsAsync = ref.watch(myProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Mi Cuenta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          profileAsync.maybeWhen(
            data: (profile) => IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => EditProfileScreen(profile: profile),
                  ),
                );
              },
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          final resolvedName = profile.displayName.isNotEmpty
              ? profile.displayName
              : 'Usuario Trueke';
          final url = profile.avatarUrl;
          final hasAvatar = url != null && url.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.surfaceMint,
                      backgroundImage: hasAvatar ? NetworkImage(url) : null,
                      child: !hasAvatar
                          ? const Icon(
                              Icons.person_outline_rounded,
                              size: 40,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    resolvedName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  liveRatingAsync.when(
                    data: (rating) => _buildLiveRatingBadge(rating),
                    error: (err, stack) =>
                        _buildLiveRatingBadge(profile.averageRating),
                    loading: () => _buildLiveRatingBadge(profile.averageRating),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildMenuTile(
                        context,
                        icon: Icons.swap_horizontal_circle_outlined,
                        title: 'Mis Ofertas de Trueke',
                        subtitle:
                            'Gestionar intercambios propuestos y recibidos',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const TradeOffersScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border,
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildMenuTile(
                        context,
                        icon: Icons.storefront_outlined,
                        title: 'Mis Productos Publicados',
                        subtitle: myProductsAsync.maybeWhen(
                          data: (list) =>
                              'Tienes ${list.length} ${list.length == 1 ? 'artículo publicado' : 'artículos publicados'}',
                          orElse: () =>
                              'Gestionar tus artículos y tu escaparate personal',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  const MyPublishedProductsScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border,
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildMenuTile(
                        context,
                        icon: Icons.currency_exchange_outlined,
                        title: 'Historial de Truekes',
                        subtitle: 'Intercambios de bienes y estado financiero',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  TruekesHistoryScreen(userId: widget.userId),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, thickness: 1, color: AppColors.border, indent: 16, endIndent: 16),
                      // Botón de Cierre de Sesión
                      InkWell(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text('Cerrar sesión'),
                              content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                  child: const Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            await ref.read(authServiceProvider).signOut();
                          }
                        },
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  'Cerrar sesión',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            )),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error al cargar perfil: $error',
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
