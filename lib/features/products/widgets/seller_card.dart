import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../../models/product.dart";
import "../../profile/providers/profile_provider.dart";
import "../../transactions/presentation/pages/user_reviews_screen.dart";
import "../../reviews/providers/reviews_provider.dart";

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

  Widget _buildProfileFallback({required bool loading}) {
    final sellerName = product.owner.trim().isNotEmpty
        ? product.owner.trim()
        : "Vendedor";

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: AppColors.surfaceMint,
          child: Icon(Icons.person_outline, color: AppColors.primary),
        ),
        title: Text(
          sellerName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            loading
                ? "Cargando perfil del vendedor..."
                : "No se ha podido cargar el perfil del vendedor",
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        trailing: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerId = product.ownerId;
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
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => UserReviewsScreen(
                        userId: profile.id,
                        userName: profile.displayName,
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
                              profile.displayName.isNotEmpty
                                  ? profile.displayName
                                  : product.owner,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Miembro verificado",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            liveRatingAsync.when(
                              data: (liveRating) => _buildRatingBadge(
                                liveRating,
                                profile.totalRatings,
                              ),
                              error: (err, stack) => _buildRatingBadge(
                                profile.averageRating,
                                profile.totalRatings,
                              ),
                              loading: () => _buildRatingBadge(
                                profile.averageRating,
                                profile.totalRatings,
                              ),
                            ),
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
          },
          error: (err, stack) => _buildProfileFallback(loading: false),
          loading: () => _buildProfileFallback(loading: true),
        ),
      ],
    );
  }
}
