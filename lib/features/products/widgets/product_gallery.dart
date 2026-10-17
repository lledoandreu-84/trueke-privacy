import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/favorites_provider.dart';
import '../../../models/product.dart';

class ProductGallery extends ConsumerWidget {
  final Product product;

  const ProductGallery({super.key, required this.product});

  // Generador minimalista de marcadores de posición satinados estilo Apple
  Widget _buildCategoryPlaceholder() {
    IconData iconData = Icons.image_outlined;

    switch (product.category) {
      case 'Electrónica':
        iconData = Icons.phone_iphone_rounded;
        break;
      case 'Moda':
        iconData = Icons.checkroom_rounded;
        break;
      case 'Hogar':
        iconData = Icons.chair_rounded;
        break;
      case 'Gaming':
        iconData = Icons.sports_esports_rounded;
        break;
      case 'Deporte':
        iconData = Icons.directions_bike_rounded;
        break;
    }

    return Container(
      color: AppColors.surfaceMint,
      child: Center(child: Icon(iconData, size: 64, color: AppColors.primary)),
    );
  }

  Widget _buildImage() {
    final bool hasValidWebImage =
        product.imageUrl.startsWith('http') &&
        !product.imageUrl.contains('unsplash.com') &&
        product.imageUrl.isNotEmpty;

    if (!hasValidWebImage) {
      return _buildCategoryPlaceholder();
    }

    return Image.network(
      product.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildCategoryPlaceholder(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesProvider);
    final isFavorite = favoritesState.maybeWhen(
      data: (favs) => favs.any((item) => item.id == product.id),
      orElse: () => false,
    );

    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: const BackButton(color: AppColors.textPrimary),
      flexibleSpace: FlexibleSpaceBar(background: _buildImage()),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
              color: isFavorite ? AppColors.coral : AppColors.primary,
              size: 22,
            ),
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(product);
            },
          ),
        ),
      ],
    );
  }
}
