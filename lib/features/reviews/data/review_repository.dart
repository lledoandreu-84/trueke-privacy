import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/review.dart';

class ReviewRepository {
  final SupabaseClient _client;
  final Future<List<Map<String, dynamic>>> Function(String userId)?
  mockGetReviewsInterceptor;

  ReviewRepository(this._client, {this.mockGetReviewsInterceptor});

  // Crear una nueva reseña tras un trueque finalizado
  Future<void> createReview(Review review) async {
    await _client.from('reviews').insert(review.toJson());
  }

  // Obtener las reseñas recibidas por un usuario específico con tipos seguros
  Future<List<Review>> getReviewsForUser(String userId) async {
    final List<dynamic> data;
    if (mockGetReviewsInterceptor != null) {
      data = await mockGetReviewsInterceptor!(userId);
    } else {
      final response = await _client
          .from('reviews')
          .select()
          .eq('reviewed_id', userId)
          .order('created_at', ascending: false);
      data = response as List<dynamic>;
    }

    return data
        .map((json) => Review.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Calcular la calificación media de un usuario manteniendo la precisión decimal
  Future<double> getUserAverageRating(String userId) async {
    final List<dynamic> data;
    if (mockGetReviewsInterceptor != null) {
      data = await mockGetReviewsInterceptor!(userId);
    } else {
      final response = await _client
          .from('reviews')
          .select('rating')
          .eq('reviewed_id', userId);
      data = response as List<dynamic>;
    }

    if (data.isEmpty) return 0.0;

    final double total = data.fold<double>(0.0, (sum, item) {
      final val = item['rating'];
      final double score = val is num ? val.toDouble() : 0.0;
      return sum + score;
    });

    return total / data.length;
  }
}
