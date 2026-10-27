import 'package:flutter_test/flutter_test.dart';
import 'package:trueke/features/chat/data/chat_repository.dart';
import 'package:trueke/features/chat/models/chat_message.dart';
import 'package:trueke/features/chat/models/chat_room.dart';

class FakeChatRepository implements ChatRepository {
  @override
  Future<List<ChatRoom>> getUserConversations() async => [];

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) => Stream.value([]);

  @override
  Stream<List<ChatRoom>> streamUserChatRooms() => Stream.value([]);

  @override
  Stream<List<ChatMessage>> streamMessages(String conversationId) => Stream.value([]);

  @override
  Future<ChatRoom> getOrCreateChatRoom({required String buyerId, required String productId, required String sellerId}) async => throw UnimplementedError();

  @override
  Future<ChatRoom> getOrCreateConversation({required String productId, required String sellerId, String? buyerId}) async => throw UnimplementedError();

  @override
  Future<void> sendMessage({
    String? conversationId,
    String? content,
    String? roomId,
    String? senderId,
    String? message,
    bool isSystem = false,
  }) async {}

  @override
  Future<String> uploadMessageImage({String? roomId, String? fileName, dynamic bytes, dynamic file}) async => '';
}

void main() {
  test('ChatRepository basic test', () {
    final repo = FakeChatRepository();
    expect(repo, isNotNull);
  });
}
