import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class NotificationTokensRepository {
  Future<void> saveToken({required String userId, required String token});
  Future<void> deleteToken({required String token});
}

class SupabaseNotificationTokensRepository
    implements NotificationTokensRepository {
  final SupabaseClient _client;
  static const _tableName = 'user_push_tokens';

  // Interceptores opcionales exclusivos para suites de pruebas automatizadas
  final Future<void> Function(Map<String, dynamic> json)?
  mockSaveTokenInterceptor;
  final Future<void> Function(String token)? mockDeleteTokenInterceptor;

  SupabaseNotificationTokensRepository(
    this._client, {
    this.mockSaveTokenInterceptor,
    this.mockDeleteTokenInterceptor,
  });

  @override
  Future<void> saveToken({
    required String userId,
    required String token,
  }) async {
    final deviceType = Platform.isAndroid
        ? 'android'
        : (Platform.isIOS ? 'ios' : 'web');

    final payload = {
      'user_id': userId,
      'token': token,
      'device_type': deviceType,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (mockSaveTokenInterceptor != null) {
      await mockSaveTokenInterceptor!(payload);
      return;
    }

    await _client.from(_tableName).upsert(payload, onConflict: 'token');
  }

  @override
  Future<void> deleteToken({required String token}) async {
    if (mockDeleteTokenInterceptor != null) {
      await mockDeleteTokenInterceptor!(token);
      return;
    }
    await _client.from(_tableName).delete().eq('token', token);
  }
}
