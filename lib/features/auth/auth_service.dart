export 'providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client.dart';
import '../profile/repositories/supabase_profile_repository.dart';

class AuthService {
  final SupabaseClient _client;
  AuthService(this._client);

  // Puente de compatibilidad estática síncrona exigido por las vistas heredadas del MVP
  static SupabaseClient get supabase => Supabase.instance.client;
  static User? get currentUser => Supabase.instance.client.auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  static String get currentUserLabel =>
      currentUser?.email?.split('@').first ?? 'Usuario';

  Future<void> _ensureProfile({
    DateTime? termsAcceptedAt,
    DateTime? privacyAcceptedAt,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final repository = SupabaseProfileRepository(_client);
    try {
      await repository.getProfile(user.id);
    } catch (_) {
      final username = user.email?.split('@').first ?? 'user';
      final now = DateTime.now().toIso8601String();
      await _client.from('profiles').insert({
        'id': user.id,
        'username': username,
        'display_name': username,
        'email': user.email ?? '',
        'avatar_url': '',
        'bio': '',
        'average_rating': 0.0,
        'total_ratings': 0,
        'created_at': now,
        'updated_at': now,
        if (termsAcceptedAt != null)
          'terms_accepted_at': termsAcceptedAt.toIso8601String(),
        if (privacyAcceptedAt != null)
          'privacy_accepted_at': privacyAcceptedAt.toIso8601String(),
      });
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
    await _ensureProfile();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    DateTime? termsAcceptedAt,
    DateTime? privacyAcceptedAt,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    if (response.session != null) {
      await _ensureProfile(
        termsAcceptedAt: termsAcceptedAt,
        privacyAcceptedAt: privacyAcceptedAt,
      );
    }
    return response.session != null;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

final authServiceProvider = Provider.autoDispose<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});
