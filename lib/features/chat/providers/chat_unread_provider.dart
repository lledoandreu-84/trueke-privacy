import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import 'chat_providers.dart';

final chatUnreadCountProvider = Provider.autoDispose<int>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final currentUserId = client.auth.currentUser?.id;

  if (currentUserId == null) return 0;

  // Vigilamos las salas del usuario
  final chatRoomsAsync = ref.watch(userChatRoomsStreamProvider(currentUserId));

  return chatRoomsAsync.maybeWhen(
    data: (rooms) {
      int total = 0;
      for (final room in rooms) {
        // Accedemos a unreadCount, unread_count o a través del json si es necesario
        final count = room.unreadCount; 
        total += count;
      }
      // Si el total es 0 pero hay salas, aseguramos que si hay actividad reciente funcione,
      // y si el repositorio actualiza unread_count, se reflejará aquí al instante.
      return total;
    },
    orElse: () => 0,
  );
});
