import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/services/supabase_realtime_service.dart';
import 'chat_providers.dart';

/// Proveedor que calcula el número total de conversaciones con actualizaciones o mensajes no leídos
final chatUnreadCountProvider = Provider.autoDispose<int>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final currentUserId = client.auth.currentUser?.id;

  if (currentUserId == null) {
    return 0;
  }

  // Obtenemos e inyectamos el canal de escucha en caliente
  final realtimeService = ref.watch(realtimeServiceProvider);

  // Escuchamos de forma activa las inserciones asíncronas distribuidas de mensajes de forma segura (Void API)
  realtimeService.subscribeToUserMessages(
    userId: currentUserId,
    onNewMessage: (payload) {
      // Forzamos la invalidación y refresco inmediato del stream de salas de chat
      ref.invalidate(userChatRoomsStreamProvider(currentUserId));
    },
  );

  final chatRoomsAsync = ref.watch(userChatRoomsStreamProvider(currentUserId));

  return chatRoomsAsync.maybeWhen(
    data: (rooms) {
      // Calcular dinámicamente el sumatorio real de mensajes no leídos del MVP en lugar de contar salas fijas
      return rooms.fold<int>(0, (sum, room) {
        final int unread = (room as dynamic).unreadCount is num
            ? ((room as dynamic).unreadCount as num).toInt()
            : 0;
        return sum + unread;
      });
    },
    orElse: () {
      return 0;
    },
  );
});
