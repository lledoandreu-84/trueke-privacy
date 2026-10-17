import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/core/supabase/supabase_client.dart';
import '../data/review_repository.dart';
import '../../../../models/review.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ReviewRepository(client);
});

final userReviewsProvider = FutureProvider.family<List<Review>, String>((
  ref,
  userId,
) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getReviewsForUser(userId);
});

final userRatingAverageProvider = FutureProvider.family<double, String>((
  ref,
  userId,
) async {
  final repo = ref.watch(reviewRepositoryProvider);
  return repo.getUserAverageRating(userId);
});
