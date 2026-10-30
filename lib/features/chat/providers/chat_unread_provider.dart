import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import 'chat_providers.dart';

final chatUnreadCountProvider = Provider.autoDispose<int>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final currentUserId = client.auth.currentUser?.id;

  if (currentUserId == null) return 0;

  // Obtenemos las salas del usuario y sumamos aquellas que tengan actividad pendiente
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
        
        // Si la sala tiene unreadCount o podemos considerarla activa
        totalUnread += unread > 0 ? unread : 0;
      }
      return totalUnread > 0 ? totalUnread : (rooms.isNotEmpty ? 0 : 0);
    },
    orElse: () => 0,
  );
});
