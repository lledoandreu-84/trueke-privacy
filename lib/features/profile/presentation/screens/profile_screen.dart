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
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
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

  Widget _buildLiveRatingBadge(double rating) {
    return Row(
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
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider(widget.userId));
    final liveRatingAsync = ref.watch(userRatingAverageProvider(widget.userId));
    final myProductsAsync = ref.watch(myProductsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Mi Cuenta',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          profileAsync.maybeWhen(
            data: (profile) => IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: theme.colorScheme.onSurface,
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
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: hasAvatar ? NetworkImage(url) : null,
                    child: !hasAvatar
                        ? Icon(
                            Icons.person_outline_rounded,
                            size: 40,
                            color: theme.colorScheme.onSurfaceVariant,
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    resolvedName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  liveRatingAsync.when(
                    data: (rating) => _buildLiveRatingBadge(rating),
                    error: (err, stack) =>
                        _buildLiveRatingBadge(profile.averageRating),
                    loading: () => _buildLiveRatingBadge(profile.averageRating),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                      width: 0.5,
                    ),
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
                        thickness: 0.5,
                        color: theme.colorScheme.outlineVariant,
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
                        thickness: 0.5,
                        color: theme.colorScheme.outlineVariant,
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
