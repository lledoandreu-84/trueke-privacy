import "../../../auth/providers/auth_provider.dart";
import 'package:trueke/features/products/providers/products_provider.dart';
import 'package:trueke/features/truekes/presentation/screens/truekes_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/offers/presentation/screens/trade_offers_screen.dart';
import 'package:trueke/features/profile/providers/profile_provider.dart';
import 'package:trueke/features/reviews/providers/reviews_provider.dart';
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
    final theme = Theme.of(context);
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
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.colorScheme.outline,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveRatingBadge(BuildContext context, double rating) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileProvider(widget.userId));
    final liveRatingAsync = ref.watch(userRatingAverageProvider(widget.userId));
    final myProductsAsync = ref.watch(myProductsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Mi Cuenta',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          profileAsync.maybeWhen(
            data: (profile) => IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: theme.colorScheme.primary,
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
                      border: Border.all(color: theme.colorScheme.primary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      backgroundImage: hasAvatar ? NetworkImage(url) : null,
                      child: !hasAvatar
                          ? Icon(
                              Icons.person_outline_rounded,
                              size: 40,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    resolvedName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  liveRatingAsync.when(
                    data: (rating) => _buildLiveRatingBadge(context, rating),
                    error: (err, stack) =>
                        _buildLiveRatingBadge(context, profile.averageRating),
                    loading: () => _buildLiveRatingBadge(context, profile.averageRating),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.03),
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
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        indent: 16,
                        endIndent: 16,
                      ),
                      InkWell(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (dialogCtx) => AlertDialog(
                              backgroundColor: theme.colorScheme.surface,
                              surfaceTintColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              title: Text(
                                'Cerrar sesión',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              content: Text(
                                '¿Estás seguro de que deseas salir de tu cuenta?',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogCtx, false),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  child: const Text('Cancelar'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(dialogCtx, true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: theme.colorScheme.error,
                                    foregroundColor: theme.colorScheme.onError,
                                    elevation: 0,
                                  ),
                                  child: const Text('Cerrar sesión'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            await ref.read(authServiceProvider).signOut();
                          }
                        },
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.logout_rounded,
                                  color: theme.colorScheme.error,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Cerrar sesión',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.w600,
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
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error al cargar perfil: $error',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
