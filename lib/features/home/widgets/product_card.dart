import '../../products/product_detail_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:trueke/core/theme/app_colors.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/features/auth/auth_service.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    final hasPrice = product.price != null && product.price! > 0;
    final formattedPrice = hasPrice 
        ? '${product.price!.toStringAsFixed(2).replaceFirst('.', ',')} €'
        : null;

    String getTradeLabel() {
      switch (product.tradeType) {
        case TradeType.trade:
          return "Trueke";
        case TradeType.sale:
          return "Venta";
        case TradeType.tradeAndMoney:
          return "Trueque + €";
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product.images.isNotEmpty
                      ? Image.network(
                          product.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final favoritesState = ref.watch(favoritesProvider);
                            final isFav = favoritesState.maybeWhen(
                              data: (favs) => favs.any((p) => p.id == product.id),
                              orElse: () => false,
                            );
                            return GestureDetector(
                              onTap: () {
                                final currentUserId = AuthService.currentUserId;
                                if (currentUserId != null && product.ownerId == currentUserId) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("No puedes añadir tu propio producto a favoritos"),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }
                                ref.read(favoritesProvider.notifier).toggleFavorite(product);
                              },
                              child: Icon(
                                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 16,
                                color: isFav ? AppColors.coral : AppColors.textPrimary,
                              ),
                            );
                          },
                        ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: hasPrice ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceMint,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasPrice ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          formattedPrice ?? getTradeLabel(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: hasPrice ? 12 : 10,
                            fontWeight: FontWeight.w800,
                          ),
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
    ),);
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: Color(0xFF94A3B8),
          size: 32,
        ),
      ),
    );
  }
}
