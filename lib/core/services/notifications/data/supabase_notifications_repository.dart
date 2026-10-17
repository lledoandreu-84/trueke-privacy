import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../features/transactions/models/notification_model.dart';
import '../domain/notifications_repository.dart';

class SupabaseNotificationsRepository implements NotificationsRepository {
  final SupabaseClient _client;
  static const _tableName = 'notifications';

  SupabaseNotificationsRepository(this._client);

  @override
  Future<List<NotificationModel>> fetchNotifications({
    required String userId,
  }) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markAsRead({required String notificationId}) async {
    await _client
        .from(_tableName)
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  @override
  Future<void> markAllAsRead({required String userId}) async {
    await _client
        .from(_tableName)
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }
}
