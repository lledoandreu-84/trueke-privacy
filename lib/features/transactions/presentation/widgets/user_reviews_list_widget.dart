import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reviews_provider.dart';
import '../../../../models/user_review.dart';

class UserReviewsListWidget extends ConsumerWidget {
  final String userId;

  const UserReviewsListWidget({super.key, required this.userId});

  Widget _buildStarsRow(BuildContext context, double rating) {
    final theme = Theme.of(context);
    final List<Widget> stars = [];
    final int fullStars = rating.floor();
    final bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 1; i <= 5; i++) {
      if (i <= fullStars) {
        stars.add(
          Icon(Icons.star_rounded, color: theme.colorScheme.primary, size: 18),
        );
      } else if (i == fullStars + 1 && hasHalfStar) {
        stars.add(
          Icon(Icons.star_half_rounded, color: theme.colorScheme.primary, size: 18),
        );
      } else {
        stars.add(
          Icon(
            Icons.star_outline_rounded,
            color: theme.colorScheme.outlineVariant,
            size: 18,
          ),
        );
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  Widget _buildSummaryHeader(BuildContext context, List<UserReview> reviews) {
    if (reviews.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    final double totalRating = reviews.fold(
      0.0,
      (sum, item) => sum + item.rating,
    );
    final double averageRating = totalRating / reviews.length;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${reviews.length} ${reviews.length == 1 ? "valoración" : "valoraciones"}',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Reputación del usuario',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    ' / 5',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              _buildStarsRow(context, averageRating),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(userReviewsProvider(userId));
    final theme = Theme.of(context);

    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Text(
                'Este usuario aún no tiene opiniones.',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryHeader(context, reviews),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                final avatarUrl = review.reviewerAvatar;

                DecorationImage? imageDecoration;
                if (avatarUrl.isNotEmpty) {
                  imageDecoration = DecorationImage(
                    image: NetworkImage(avatarUrl),
                    fit: BoxFit.cover,
                  );
                }

                Widget? avatarChild;
                if (avatarUrl.isEmpty) {
                  avatarChild = Icon(
                    Icons.person_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  );
                }

                String resolvedName = 'Anónimo';
                if (review.reviewerName.isNotEmpty) {
                  resolvedName = review.reviewerName;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          image: imageDecoration,
                        ),
                        child: avatarChild,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    resolvedName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurface,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${review.rating.toStringAsFixed(0)}.0',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              review.comment,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Error al cargar las valoraciones',
            style: TextStyle(
              color: theme.colorScheme.error,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
