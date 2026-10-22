import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_profile.dart';
import '../../models/user_review.dart';
import '../domain/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _client;

  SupabaseProfileRepository(this._client);

  static const String _tableName = 'profiles';

  @override
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    try {
      await _client
          .from(_tableName)
          .update(profile.toJson())
          .eq('id', profile.id);
    } catch (e) {
      throw Exception('Error al actualizar el perfil: $e');
    }
  }

  @override
  Future<List<UserReview>> getUserReviews(String userId) async {
    try {
      final response = await _client
          .from('user_reviews')
          .select('*, profiles!user_reviews_reviewer_id_fkey(display_name, avatar_url)')
          .eq('receiver_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        final profile = json['profiles'] as Map<String, dynamic>?;
        return UserReview.fromJson(json).copyWith(
          reviewerName: profile?['display_name'] as String? ?? 'Usuario',
          reviewerAvatar: profile?['avatar_url'] as String? ?? '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> createReview({
    required String receiverId,
    required double rating,
    required String comment,
  }) async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null) {
      throw Exception('Debes iniciar sesión.');
    }

    await _client.from('user_reviews').insert({
      'reviewer_id': myId,
      'receiver_id': receiverId,
      'rating': rating,
      'comment': comment,
    });
  }
}
