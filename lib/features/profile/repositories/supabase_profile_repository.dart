import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/profile/models/user_profile.dart';
import 'package:trueke/models/user_review.dart';
import 'package:trueke/features/profile/domain/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _client;
  final Future<Map<String, dynamic>?> Function(String)? _mockGetProfileInterceptor;
  final Future<void> Function(UserProfile)? _mockUpdateProfileInterceptor;

  static const String _tableName = 'profiles';

  SupabaseProfileRepository(
    this._client, {
    this._mockGetProfileInterceptor,
    this._mockUpdateProfileInterceptor,
  });

  @override
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final interceptor = _mockGetProfileInterceptor;
      if (interceptor != null) {
        final res = await interceptor(userId);
        if (res == null) return null;
        return UserProfile.fromJson(res);
      }
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
      final json = Map<String, dynamic>.from(profile.toJson());
      json.remove('created_at');

      final interceptor = _mockUpdateProfileInterceptor;
      if (interceptor != null) {
        final cleanProfile = UserProfile.fromJson({
          ...profile.toJson(),
        });
        await interceptor(cleanProfile);
        return;
      }
      await _client
          .from(_tableName)
          .update(json)
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
          .select()
          .eq('receiver_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserReview.fromJson(json).copyWith(
                reviewerName: json['reviewer_name'] ?? 'Usuario',
                reviewerAvatar: json['reviewer_avatar'] ?? '',
              ))
          .toList();
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
