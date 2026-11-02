import 'package:trueke/models/product.dart';
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

final userChatRoomsStreamProvider = StreamProvider.family<List<ChatRoom>, String?>((ref, userId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.streamUserChatRooms();
});

final singleChatRoomProvider = StreamProvider.family<ChatRoom?, String>((ref, roomId) async* {
  yield null;
});

final chatProductProvider = FutureProvider.family<Product?, String>((ref, productId) async {
  ref.keepAlive();
  // Forzamos a que no mantenga caché por mucho tiempo
  Future.delayed(const Duration(seconds: 1), () => ref.invalidateSelf());
  if (productId.isEmpty) return null;
  try {
    // 1. Intentar buscar por ID exacto
    var response = await Supabase.instance.client
        .from('products')
        .select('*')
        .eq('id', productId)
        .maybeSingle();
    
    

    if (response == null) return null;
    return Product.fromJson(response);
  } catch (_) {
    return null;
  }
});
