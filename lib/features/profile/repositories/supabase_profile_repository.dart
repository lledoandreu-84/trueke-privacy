import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/profile/models/user_profile.dart';
import '../../../models/user_review.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile(String id);
  Future<void> updateProfile(UserProfile profile);
  Future<List<UserReview>> getUserReviews(String userId);
  Future<void> createReview({
    required String receiverId,
    required double rating,
    required String comment,
  });
}

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _client;
  static const _tableName = 'profiles';

  // Interceptores nominales opcionales diseñados exclusivamente para pruebas unitarias
  final Future<Map<String, dynamic>> Function(String id)?
  mockGetProfileInterceptor;
  final Future<void> Function(Map<String, dynamic> json)?
  mockUpdateProfileInterceptor;

  SupabaseProfileRepository(
    this._client, {
    this.mockGetProfileInterceptor,
    this.mockUpdateProfileInterceptor,
  });

  @override
  Future<UserProfile> getProfile(String id) async {
    if (id.isEmpty) {
      throw Exception('ID de usuario inválido o no autenticado');
    }

    if (mockGetProfileInterceptor != null) {
      final response = await mockGetProfileInterceptor!(id);
      return UserProfile.fromJson(response);
    }

    final response = await _client
        .from(_tableName)
        .select()
        .eq('id', id)
        .single();
    return UserProfile.fromJson(response);
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final updates = profile.toJson();
    updates.remove('created_at');
    updates['updated_at'] = DateTime.now().toIso8601String();

    if (mockUpdateProfileInterceptor != null) {
      await mockUpdateProfileInterceptor!(updates);
      return;
    }

    await _client.from(_tableName).update(updates).eq('id', profile.id);
  }

  @override
  Future<List<UserReview>> getUserReviews(String userId) async {
    try {
      final response = await _client
          .from('user_reviews')
          .select(
            '*, profiles!user_reviews_reviewer_id_fkey(display_name, avatar_url)',
          )
          .eq('receiver_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>).map((json) {
        final map = json as Map<String, dynamic>;
        final profile = map['profiles'] as Map<String, dynamic>?;
        return UserReview(
          id: map['id'] as String,
          truekeId: map['trueke_id'] as String? ?? '',
          reviewerId: map['reviewer_id'] as String? ?? '',
          reviewedId: map['receiver_id'] as String? ?? '',
          rating: (map['rating'] as num? ?? 0.0).toDouble(),
          comment: map['comment'] as String? ?? '',
          createdAt: map['created_at'] != null
              ? DateTime.parse(map['created_at'] as String)
              : DateTime.now(),
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

    final myProfileResponse = await _client
        .from(_tableName)
        .select()
        .eq('id', myId)
        .maybeSingle();

    final myName = myProfileResponse != null
        ? (myProfileResponse['display_name'] ??
              myProfileResponse['username'] ??
              'Usuario')
        : 'Usuario';
    final myAvatar = myProfileResponse != null
        ? (myProfileResponse['avatar_url'] ?? '')
        : '';

    await _client.from('user_reviews').insert({
      'reviewer_id': myId,
      'reviewer_name': myName,
      'reviewer_avatar': myAvatar,
      'receiver_id': receiverId,
      'rating': rating,
      'comment': comment,
    });
  }
}
