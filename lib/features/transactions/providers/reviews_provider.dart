import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/models/user_review.dart';
import 'package:trueke/features/profile/providers/profile_provider.dart';

final userReviewsProvider = FutureProvider.family
    .autoDispose<List<UserReview>, String>((ref, userId) async {
      final repository = ref.watch(supabaseProfileRepositoryProvider);
      return repository.getUserReviews(userId);
    });
