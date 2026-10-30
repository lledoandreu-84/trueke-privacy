import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/services/supabase_realtime_service.dart';
import 'chat_providers.dart';

/// Proveedor que calcula el número total de conversaciones con mensajes no leídos
final chatUnreadCountProvider = Provider.autoDispose<int>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final currentUserId = client.auth.currentUser?.id;

  if (currentUserId == null) {
    return 0;
  }

  // Obtenemos e inyectamos el canal de escucha en caliente para nuevos mensajes
  final realtimeService = ref.watch(realtimeServiceProvider);

  realtimeService.subscribeToUserMessages(
    userId: currentUserId,
    onNewMessage: (payload) {
      ref.invalidate(userChatRoomsStreamProvider(currentUserId));
    },
  );

  final chatRoomsAsync = ref.watch(userChatRoomsStreamProvider(currentUserId));

  return chatRoomsAsync.maybeWhen(
    data: (rooms) {
      int totalUnread = 0;
      for (final room in rooms) {
        final r = room as dynamic;
        int unread = 0;
        try {
          unread = r.unreadCount is num ? (r.unreadCount as num).toInt() : 0;
        } catch (_) {}
        
        totalUnread += (unread > 0 ? unread : (rooms.isNotEmpty ? 1 : 0));
      }
      return totalUnread;
    },
    orElse: () => 0,
  );
});
