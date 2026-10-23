import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/core/supabase/supabase_client.dart';
import '../../../auth/auth_service.dart';

/// Notifier que expone el conteo elástico reactivo de notificaciones y mensajes no leídos
class UnreadNotificationsNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() {
    if (state > 0) state--;
  }

  void reset() => state = 0;
}

/// Proveedor global para el Badge Rojo de Navegación del Scaffold principal
final unreadNotificationsCountProvider =
    NotifierProvider<UnreadNotificationsNotifier, int>(() {
      return UnreadNotificationsNotifier();
    });

/// Escuchador en caliente perimetral que se conecta a Supabase Realtime
final inAppNotificationListenerProvider = Provider.autoDispose<void>((ref) {
  final currentUserId = ref.watch(authUserIdProvider).value;
  if (currentUserId == null) return;

  final client = ref.watch(supabaseClientProvider);
  final countNotifier = ref.read(unreadNotificationsCountProvider.notifier);

  // 1. Canal Realtime para Mensajes de Chat
  final chatChannel = client
      .channel('public:chat_messages')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'chat_messages',
        callback: (payload) {
          final record = payload.newRecord;
          final senderId = record['sender_id']?.toString();
          if (senderId != null && senderId != currentUserId) {
            countNotifier.increment();
            debugPrint(
              'Mensaje en tiempo real capturado. Incrementando badge.',
            );
          }
        },
      )
      .subscribe();

  // 2. Canal Realtime para la Tabla de Alertas Core del Sistema (Escrow / Disputes)
  final notifyChannel = client
      .channel('public:notifications')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'notifications',
        callback: (payload) {
          final record = payload.newRecord;
          final userId = record['user_id']?.toString();
          if (userId == currentUserId) {
            countNotifier.increment();
            debugPrint(
              'Notificación del sistema capturada. Incrementando badge.',
            );
          }
        },
      )
      .subscribe();

  ref.onDispose(() {
    client.removeChannel(chatChannel);
    client.removeChannel(notifyChannel);
  });
});

/// Banner visual minimalista adaptado a los lineamientos estéticos de Material 3
class InAppNotificationBanner {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onInverseSurface,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onInverseSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        
      ),
    );
  }
}
