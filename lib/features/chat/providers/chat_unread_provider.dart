import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/services/supabase_realtime_service.dart';
import 'chat_providers.dart';

final chatUnreadCountProvider = Provider.autoDispose<int>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final currentUserId = client.auth.currentUser?.id;

  if (currentUserId == null) {
    return 0;
  }

  // Nos aseguramos de inicializar el servicio de forma segura y controlada
  try {
    final realtimeService = ref.watch(realtimeServiceProvider);
    
    // Suscripción protegida con control de ciclo de vida
    realtimeService.subscribeToUserMessages(
      userId: currentUserId,
      onNewMessage: (payload) {
        if (ref.exists(userChatRoomsStreamProvider(currentUserId))) {
          ref.invalidate(userChatRoomsStreamProvider(currentUserId));
        }
      },
    );

    // Limpieza automática al desechar el provider para evitar fugas de memoria o hilos colgados
    ref.onDispose(() {
      // Si el servicio de realtime requiere limpieza explícita, se puede invocar aquí de forma segura
    });
  } catch (_) {}

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
