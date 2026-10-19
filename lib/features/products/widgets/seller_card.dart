import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product.dart';
import '../../profile/providers/profile_provider.dart';
import '../../transactions/presentation/pages/user_reviews_screen.dart';
import '../../reviews/providers/reviews_provider.dart';

class SellerCard extends ConsumerWidget {
  final Product product;

  const SellerCard({super.key, required this.product});

  Widget _buildRatingBadge(double rating, int totalRatings) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
        const SizedBox(width: 4),
        Text(
          "${rating.toStringAsFixed(1)} ($totalRatings)",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildSellerContent(BuildContext context, {required String name, required double rating, required int totalRatings, required String userId, bool isFallback = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: userId.isEmpty ? null : () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => UserReviewsScreen(
                userId: userId,
                userName: name,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isFallback ? "Vendedor en Trueke" : "Miembro verificado",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildRatingBadge(rating, totalRatings),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerId = product.ownerId;
    final fallbackName = product.owner.trim().isNotEmpty ? product.owner.trim() : "Vendedor";

    if (sellerId.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vendedor",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),
          _buildSellerContent(context, name: fallbackName, rating: 0.0, totalRatings: 0, userId: '', isFallback: true),
        ],
      );
    }

    final profileAsync = ref.watch(userProfileProvider(sellerId));
    final liveRatingAsync = ref.watch(userRatingAverageProvider(sellerId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Vendedor",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 12),
        profileAsync.when(
          data: (profile) {
            final displayName = profile.displayName.isNotEmpty ? profile.displayName : fallbackName;
            final rating = liveRatingAsync.asData?.value ?? profile.averageRating;
            return _buildSellerContent(
              context,
              name: displayName,
              rating: rating,
              totalRatings: profile.totalRatings,
              userId: profile.id,
            );
          },
          error: (err, stack) => _buildSellerContent(
            context,
            name: fallbackName,
            rating: 0.0,
            totalRatings: 0,
            userId: sellerId,
            isFallback: true,
          ),
          loading: () => _buildSellerContent(
            context,
            name: fallbackName,
            rating: 0.0,
            totalRatings: 0,
            userId: sellerId,
            isFallback: true,
          ),
        ),
      ],
    );
  }
}
