import 'package:trueke/features/profile/models/user_profile.dart';
import 'package:trueke/models/user_review.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile(String userId);
  Future<void> updateProfile(UserProfile profile);
  Future<List<UserReview>> getUserReviews(String userId);
  Future<void> createReview({
    required String receiverId,
    required double rating,
    required String comment,
  });
}
