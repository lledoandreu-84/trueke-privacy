import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import 'chat_providers.dart';

final chatUnreadCountProvider = Provider.autoDispose<int>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final currentUserId = client.auth.currentUser?.id;

  if (currentUserId == null) return 0;

  // Escuchamos el stream de salas de chat de forma segura
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
        
        totalUnread += unread > 0 ? unread : 0;
      }
      return totalUnread;
    },
    orElse: () => 0,
  );
});
