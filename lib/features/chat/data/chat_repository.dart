import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';

abstract class ChatRepository {
  Future<void> markChatAsRead(String conversationId);
  Future<void> deleteConversation(String conversationId);
  Future<void> deleteConversationsByProduct(String productId);
  Future<List<ChatRoom>> getUserConversations();
  Stream<List<ChatMessage>> watchMessages(String conversationId);
  Stream<List<ChatRoom>> streamUserChatRooms();
  Stream<List<ChatMessage>> streamMessages(String conversationId);
  Future<ChatRoom> getOrCreateChatRoom({
    required String buyerId,
    required String productId,
    required String sellerId,
  });
  Future<ChatRoom> getOrCreateConversation({
    required String productId,
    required String sellerId,
    String? buyerId,
  });
  Future<void> sendMessage({
    String? conversationId,
    String? content,
    String? roomId,
    String? senderId,
    String? message,
    bool isSystem = false,
  });
    
  Future<String> uploadMessageImage({
    String? roomId,
    String? fileName,
    dynamic bytes,
    dynamic file,
  });
}

class SupabaseChatRepository implements ChatRepository {
  @override
  Future<void> markChatAsRead(String conversationId) async {
    if (conversationId.trim().isEmpty) return;
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    final convo = await _client.from('conversations').select('buyer_id, seller_id').eq('id', conversationId).maybeSingle();
    if (convo != null) {
      if (userId == convo['buyer_id']) {
        await _client.from('conversations').update({'unread_buyer': 0}).eq('id', conversationId);
      } else if (userId == convo['seller_id']) {
        await _client.from('conversations').update({'unread_seller': 0}).eq('id', conversationId);
      }
    }
  }
  @override
  Future<void> deleteConversation(String conversationId) async {
    if (conversationId.trim().isEmpty) return;
    await _client.from('conversations').delete().eq('id', conversationId);
  }
  final SupabaseClient? _supabase;
  final dynamic mockInsertInterceptor;
  final dynamic mockStreamMessagesInterceptor;

  SupabaseChatRepository(
    this._supabase, {
    this.mockInsertInterceptor,
    this.mockStreamMessagesInterceptor,
  });

  SupabaseClient get _client => _supabase ?? Supabase.instance.client;

  @override
  Future<List<ChatRoom>> getUserConversations() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('conversations')
        .select()
        .or('buyer_id.eq.$userId,seller_id.eq.$userId')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ChatRoom.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Stream<List<ChatRoom>> streamUserChatRooms() async* {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      yield [];
      return;
    }

    try {
      final initialData = await _client
          .from('conversations')
          .select()
          .or('buyer_id.eq.$userId,seller_id.eq.$userId')
          .order('created_at', ascending: false);
      
      yield (initialData as List)
          .map((json) => ChatRoom.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      yield [];
    }

    yield* _client
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data
            .map((json) => ChatRoom.fromJson(json))
            .where((c) => c.buyerId == userId || c.sellerId == userId)
            .toList());
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    if (conversationId.trim().isEmpty) {
      return Stream.value([]);
    }
    if (mockStreamMessagesInterceptor != null) {
      return mockStreamMessagesInterceptor(conversationId);
    }
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .map((data) => data.map((json) => ChatMessage.fromJson(json)).toList());
  }

  @override
  Stream<List<ChatMessage>> streamMessages(String conversationId) {
    return watchMessages(conversationId);
  }

  @override
  Future<ChatRoom> getOrCreateChatRoom({
    required String buyerId,
    required String productId,
    required String sellerId,
  }) async {
    return getOrCreateConversation(
      productId: productId,
      sellerId: sellerId,
      buyerId: buyerId,
    );
  }

  @override
  Future<ChatRoom> getOrCreateConversation({
    required String productId,
    required String sellerId,
    String? buyerId,
  }) async {
    final currentUserId = buyerId ?? _client.auth.currentUser?.id;
    if (currentUserId == null) {
      throw Exception('Usuario no autenticado.');
    }

    if (currentUserId == sellerId) {
      throw Exception('No puedes iniciar una conversación contigo mismo.');
    }

    final existing = await _client
        .from('conversations')
        .select()
        .eq('product_id', productId)
        .eq('buyer_id', currentUserId)
        .maybeSingle();

    if (existing != null) {
      return ChatRoom.fromJson(existing);
    }

    final response = await _client
        .from('conversations')
        .insert({
          'product_id': productId,
          'buyer_id': currentUserId,
          'seller_id': sellerId,
        })
        .select()
        .single();

    return ChatRoom.fromJson(response);
  }

  @override
  Future<void> sendMessage({
    String? conversationId,
    String? content,
    String? roomId,
    String? senderId,
    String? message,
    bool isSystem = false,
  }) async {
    final targetId = conversationId ?? roomId ?? '';
    final finalContent = content ?? message ?? '';
    final currentSenderId = senderId ?? _client.auth.currentUser?.id ?? '';

    if (targetId.trim().isEmpty || finalContent.trim().isEmpty) return;

    if (mockInsertInterceptor != null) {
      await mockInsertInterceptor(targetId, finalContent, currentSenderId);
      return;
    }

    // 1. Insertar el mensaje en el chat
    await _client.from('messages').insert({
      'conversation_id': targetId,
      'sender_id': currentSenderId,
      'content': finalContent.trim(),
    });

    // 1.1 Incrementar el contador de no leídos para el destinatario
    try {
      final convoData = await _client
          .from('conversations')
          .select('buyer_id, seller_id, unread_buyer, unread_seller')
          .eq('id', targetId)
          .maybeSingle();

      if (convoData != null) {
        final buyerId = convoData['buyer_id'] as String?;
        final sellerId = convoData['seller_id'] as String?;
        
        if (currentSenderId == buyerId) {
          // Si envía el comprador, incrementa el del vendedor
          final count = (convoData['unread_seller'] as num?)?.toInt() ?? 0;
          await _client.from('conversations').update({'unread_seller': count + 1}).eq('id', targetId);
        } else if (currentSenderId == sellerId) {
          // Si envía el vendedor, incrementa el del comprador
          final count = (convoData['unread_buyer'] as num?)?.toInt() ?? 0;
          await _client.from('conversations').update({'unread_buyer': count + 1}).eq('id', targetId);
        }
      }
    } catch (_) {}

    // 2. Crear la notificación in-app para el destinatario de forma automática
    try {
      final convo = await _client
          .from('conversations')
          .select()
          .eq('id', targetId)
          .maybeSingle();

      if (convo != null) {
        final buyerId = convo['buyer_id'] as String?;
        final sellerId = convo['seller_id'] as String?;
        
        final recipientId = (currentSenderId == buyerId) ? sellerId : buyerId;

        if (recipientId != null && recipientId != currentSenderId) {
          await _client.from('notifications').insert({
            'user_id': recipientId,
            'title': 'Nuevo mensaje de chat',
            'message': finalContent.trim(),
            'type': 'chat',
          });
        }
      }
    } catch (_) {
      // Fallback silencioso para no bloquear el flujo de chat
    }
  }

  @override
  Future<String> uploadMessageImage({
    String? roomId,
    String? fileName,
    dynamic bytes,
    dynamic file,
  }) async {
    return '';
  }
  
  @override
  Future<void> deleteConversationsByProduct(String productId) async {
    if (productId.trim().isEmpty) return;
    await _client.from('conversations').delete().eq('product_id', productId);
  }
}
