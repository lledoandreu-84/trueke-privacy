import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import 'chat_providers.dart';

final chatUnreadCountProvider = Provider.autoDispose<int>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final currentUserId = client.auth.currentUser?.id;

  if (currentUserId == null) return 0;

  // Obtenemos las salas de chat del usuario actual
  final chatRoomsAsync = ref.watch(userChatRoomsStreamProvider(currentUserId));

  return chatRoomsAsync.maybeWhen(
    data: (rooms) {
      int totalUnread = 0;
      for (final room in rooms) {
        final r = room as dynamic;
        // Si la sala involucra al usuario y no es el último emisor, o tiene un contador pendiente
        if (r.buyerId == currentUserId || r.sellerId == currentUserId) {
          int unread = 0;
          try {
            unread = r.unreadCount is num ? (r.unreadCount as num).toInt() : 0;
          } catch (_) {}
          
          totalUnread += unread > 0 ? unread : 0;
        }
      }
      // Fallback dinámico: si hay salas pero no se mapea unreadCount, forzamos 1 si hay actividad reciente o dejamos que el stream actúe
      return totalUnread;
    },
    orElse: () => 0,
  );
});
