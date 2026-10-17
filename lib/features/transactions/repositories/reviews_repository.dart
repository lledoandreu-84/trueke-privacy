import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/user_review.dart';

abstract class ReviewsRepository {
  Future<List<UserReview>> getUserReviews(String userId);
  Future<void> addReview({
    required String reviewerId,
    required String receiverId,
    required double rating,
    required String comment,
  });
}

class SupabaseReviewsRepository implements ReviewsRepository {
  SupabaseReviewsRepository(this._client);

  final SupabaseClient _client;
  static const _tableName = 'user_reviews';

  @override
  Future<List<UserReview>> getUserReviews(String userId) async {
    // Realizamos una consulta relacional limpia hacia el perfil del reseñador
    final response = await _client
        .from(_tableName)
        .select(
          '*, profiles!user_reviews_reviewer_id_fkey(display_name, avatar_url)',
        )
        .eq('receiver_id', userId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((json) {
      final map = json as Map<String, dynamic>;
      final profile = map['profiles'] as Map<String, dynamic>?;

      DateTime resolvedDate = DateTime.now();
      if (map['created_at'] != null) {
        resolvedDate = DateTime.parse(map['created_at'] as String);
      }

      return UserReview(
        id: map['id'] as String,
        truekeId: map['trueke_id'] as String? ?? '',
        reviewerId: map['reviewer_id'] as String? ?? '',
        reviewedId: map['receiver_id'] as String? ?? '',
        rating: (map['rating'] as num? ?? 0.0).toDouble(),
        comment: map['comment'] as String? ?? '',
        createdAt: resolvedDate,
        reviewerName: profile?['display_name'] as String? ?? 'Usuario',
        reviewerAvatar: profile?['avatar_url'] as String? ?? '',
      );
    }).toList();
  }

  @override
  Future<void> addReview({
    required String reviewerId,
    required String receiverId,
    required double rating,
    required String comment,
  }) async {
    // Insertamos estrictamente los datos puros exigidos por el blindaje de la BD
    await _client.from(_tableName).insert({
      'reviewer_id': reviewerId,
      'receiver_id': receiverId,
      'rating': rating,
      'comment': comment.trim(),
    });
  }
}
