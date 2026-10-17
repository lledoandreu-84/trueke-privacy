import '../models/chat_room.dart';
import '../models/chat_message.dart';
import 'dart:typed_data';

abstract class ChatRepository {
  Future<ChatRoom> getOrCreateChatRoom({
    required String productId,
    required String buyerId,
    required String sellerId,
  });

  Stream<List<ChatMessage>> streamMessages(String roomId);

  Future<void> sendTradeOffer({
    required String roomId,
    required String senderId,
    required String message,
    required String offerId,
  });

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String message,
    bool isSystem = false,
  });

  Stream<List<ChatRoom>> streamUserChatRooms(String userId);
  Future<String> uploadMessageImage({
    required String roomId,
    required String fileName,
    required Uint8List bytes,
  });
}
