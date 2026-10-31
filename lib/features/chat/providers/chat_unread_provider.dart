import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/features/chat/providers/chat_providers.dart';

final chatUnreadCountProvider = Provider<int>((ref) {
  final user = ref.watch(currentUserProvider);
  final userId = user?.id ?? '';
  
  if (userId.isEmpty) return 0;

  final roomsAsync = ref.watch(userChatRoomsStreamProvider(userId));

  return roomsAsync.when(
    data: (rooms) {
      int total = 0;
      for (final room in rooms) {
        final count = room.getUnreadCountForUser(userId);
        total += count;
      }
      return total;
    },
    loading: () => 0,
    error: (_, _) => 0,
  );
});