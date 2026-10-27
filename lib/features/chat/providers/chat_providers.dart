import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/chat_repository.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return SupabaseChatRepository(Supabase.instance.client);
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, conversationId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchMessages(conversationId);
});

final chatMessagesStreamProvider = chatMessagesProvider;

final userConversationsProvider = StreamProvider<List<ChatRoom>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.streamUserChatRooms();
});

final userChatRoomsStreamProvider = Provider.family<AsyncValue<List<ChatRoom>>, String?>((ref, userId) {
  return ref.watch(userConversationsProvider);
});

final singleChatRoomProvider = StreamProvider.family<ChatRoom?, String>((ref, roomId) async* {
  yield null;
});

final chatProductProvider = FutureProvider.family<dynamic, String>((ref, productId) async {
  return null;
});
