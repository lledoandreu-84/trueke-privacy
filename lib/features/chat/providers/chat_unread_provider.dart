import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/services/supabase_realtime_service.dart';
import 'chat_providers.dart';

final chatUnreadCountProvider = Provider.autoDispose<int>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final currentUserId = client.auth.currentUser?.id;

  if (currentUserId == null) return 0;

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
        
        // Sumar únicamente si hay mensajes no leídos reales (sin recuento ficticio por sala)
        totalUnread += unread > 0 ? unread : 0;
      }
      return totalUnread;
    },
    orElse: () => 0,
  );
});
