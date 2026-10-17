import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../supabase/supabase_client.dart';
import '../../../../features/auth/auth_service.dart';
import '../../../../features/transactions/models/notification_model.dart';
import '../data/supabase_notifications_repository.dart';
import '../domain/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseNotificationsRepository(client);
});

class NotificationsHistoryNotifier
    extends AsyncNotifier<List<NotificationModel>> {
  RealtimeChannel? _channel;

  @override
  Future<List<NotificationModel>> build() async {
    final userIdAsync = ref.watch(authUserIdProvider);
    final userId = userIdAsync.value;

    if (userId == null) {
      return [];
    }

    final repository = ref.watch(notificationsRepositoryProvider);
    final client = ref.watch(supabaseClientProvider);

    // Regla de Oro nº 2: El registro de limpieza se ancla de forma inquebrantable en la raiz del ciclo de vida
    ref.onDispose(() {
      _channel?.unsubscribe();
    });

    _initRealtimeSubscription(client, userId);
    return repository.fetchNotifications(userId: userId);
  }

  void _initRealtimeSubscription(SupabaseClient client, String userId) {
    _channel?.unsubscribe();

    _channel = client
        .channel('public:notifications:user_id=eq.$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            // Protección defensiva para evitar StateError si el provider está en dispose o sin escuchadores activos
            if (state.isLoading) return;

            final eventType = payload.eventType;
            final currentList = List<NotificationModel>.from(state.value ?? []);

            if (eventType == PostgresChangeEvent.insert) {
              final newNotification = NotificationModel.fromJson(
                payload.newRecord,
              );
              if (!currentList.any((n) => n.id == newNotification.id)) {
                state = AsyncData([newNotification, ...currentList]);
              }
            } else if (eventType == PostgresChangeEvent.update) {
              final updatedNotification = NotificationModel.fromJson(
                payload.newRecord,
              );
              state = AsyncData(
                currentList
                    .map(
                      (n) => n.id == updatedNotification.id
                          ? updatedNotification
                          : n,
                    )
                    .toList(),
              );
            } else if (eventType == PostgresChangeEvent.delete) {
              final oldId = payload.oldRecord['id'] as String?;
              if (oldId != null) {
                state = AsyncData(
                  currentList.where((n) => n.id != oldId).toList(),
                );
              }
            }
          },
        );

    _channel?.subscribe();
  }

  Future<void> markAsRead(String notificationId) async {
    final currentList = state.value ?? [];

    state = AsyncData(
      currentList
          .map(
            (n) => n.id == notificationId
                ? NotificationModel(
                    id: n.id,
                    userId: n.userId,
                    title: n.title,
                    message: n.message,
                    type: n.type,
                    isRead: true,
                    createdAt: n.createdAt,
                  )
                : n,
          )
          .toList(),
    );

    try {
      final repository = ref.read(notificationsRepositoryProvider);
      await repository.markAsRead(notificationId: notificationId);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      ref.invalidateSelf();
    }
  }

  Future<void> markAllAsRead() async {
    final userId = ref.read(authUserIdProvider).value;
    if (userId == null) return;

    final currentList = state.value ?? [];
    state = AsyncData(
      currentList
          .map(
            (n) => NotificationModel(
              id: n.id,
              userId: n.userId,
              title: n.title,
              message: n.message,
              type: n.type,
              isRead: true,
              createdAt: n.createdAt,
            ),
          )
          .toList(),
    );

    try {
      final repository = ref.read(notificationsRepositoryProvider);
      await repository.markAllAsRead(userId: userId);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      ref.invalidateSelf();
    }
  }
}

final notificationsHistoryProvider =
    AsyncNotifierProvider<
      NotificationsHistoryNotifier,
      List<NotificationModel>
    >(NotificationsHistoryNotifier.new);
