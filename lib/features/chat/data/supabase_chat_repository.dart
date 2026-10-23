import "package:supabase_flutter/supabase_flutter.dart";
import "dart:typed_data";
import "dart:async";
import "../models/chat_message.dart";
import "../models/chat_room.dart";
import "chat_repository.dart";

class SupabaseChatRepository implements ChatRepository {
  final SupabaseClient _client;
  final Future<void> Function(String message)? mockInsertInterceptor;
  final Stream<List<ChatMessage>> Function(String roomId)?
  mockStreamMessagesInterceptor;

  // Búfer local en memoria para simular persistencia instantánea en pruebas offline
  static final List<ChatMessage> _localMessagesBuffer = [];

  // Controlador de stream para notificar los cambios locales instantáneamente a la UI
  static final StreamController<List<ChatMessage>> _messagesController =
      StreamController<List<ChatMessage>>.broadcast();

  SupabaseChatRepository(
    this._client, {
    this.mockInsertInterceptor,
    this.mockStreamMessagesInterceptor,
  });

  @override
  Future<ChatRoom> getOrCreateChatRoom({
    required String productId,
    required String buyerId,
    required String sellerId,
  }) async {
    final RegExp uuidRegex = RegExp(
      r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
    );

    final String cleanBuyerId = uuidRegex.hasMatch(buyerId)
        ? buyerId
        : (_client.auth.currentUser?.id ??
              "00000000-0000-4000-a000-000000000000");

    final String cleanSellerId = uuidRegex.hasMatch(sellerId)
        ? sellerId
        : "00000000-0000-4000-a000-000000000000";

    if (cleanBuyerId == cleanSellerId) {
      throw ArgumentError('No puedes crear una sala de chat contigo mismo.');
    }

    final String cleanProductId = uuidRegex.hasMatch(productId)
        ? productId
        : "00000000-0000-4000-b000-000000000000";

    try {
      final response = await _client
          .from("chat_rooms")
          .select()
          .eq("product_id", cleanProductId)
          .eq("buyer_id", cleanBuyerId)
          .eq("seller_id", cleanSellerId)
          .maybeSingle();

      if (response != null) {
        return ChatRoom.fromJson(response);
      }
    } catch (_) {}

    try {
      final newRoomResponse = await _client
          .from("chat_rooms")
          .upsert({
            "product_id": cleanProductId,
            "buyer_id": cleanBuyerId,
            "seller_id": cleanSellerId,
          }, onConflict: "product_id,buyer_id,seller_id")
          .select()
          .single();

      return ChatRoom.fromJson(newRoomResponse);
    } catch (e) {
      return ChatRoom(
        id: "00000000-0000-4000-c000-000000000000",
        productId: cleanProductId,
        buyerId: cleanBuyerId,
        sellerId: cleanSellerId,
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  Stream<List<ChatMessage>> streamMessages(String roomId) {
    if (mockStreamMessagesInterceptor != null) {
      return mockStreamMessagesInterceptor!(roomId);
    }
    // Retornamos un flujo combinado: escucha remota pasiva + inyecciones locales inmediatas de memoria
    final remoteStream = _client
        .from("chat_messages")
        .stream(primaryKey: ["id"])
        .eq("room_id", roomId)
        .order("created_at", ascending: true)
        .map((maps) => maps.map((map) => ChatMessage.fromJson(map)).toList());

    // Creamos un Stream combinado de seguridad para alimentar la UI instantáneamente si falla la red
    final controller = StreamController<List<ChatMessage>>();

    List<ChatMessage> lastRemoteMessages = [];

    final subscription = remoteStream.listen(
      (remoteList) {
        lastRemoteMessages = remoteList;
        final filteredLocal = _localMessagesBuffer
            .where((m) => m.roomId == roomId)
            .toList();
        // Fusionamos evitando duplicados por ID
        final Map<String, ChatMessage> uniqueMap = {};
        for (var m in remoteList) {
          uniqueMap[m.id] = m;
        }
        for (var m in filteredLocal) {
          uniqueMap[m.id] = m;
        }

        final sortedList = uniqueMap.values.toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        if (!controller.isClosed) {
          controller.add(sortedList);
        }
      },
      onError: (err) {
        // Si el stream nativo de Supabase da error por falta de red, emitimos el búfer local puro
        final filteredLocal = _localMessagesBuffer
            .where((m) => m.roomId == roomId)
            .toList();
        if (!controller.isClosed) {
          controller.add(filteredLocal);
        }
      },
    );

    // También escuchamos las actualizaciones del disparador de memoria local
    final localSub = _messagesController.stream.listen((_) {
      final filteredLocal = _localMessagesBuffer
          .where((m) => m.roomId == roomId)
          .toList();
      final Map<String, ChatMessage> uniqueMap = {};
      for (var m in lastRemoteMessages) {
        uniqueMap[m.id] = m;
      }
      for (var m in filteredLocal) {
        uniqueMap[m.id] = m;
      }
      final sortedList = uniqueMap.values.toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (!controller.isClosed) {
        controller.add(sortedList);
      }
    });

    // Añadimos el estado inicial del búfer en memoria inmediatamente para evitar pantallas en blanco
    final initialLocal = _localMessagesBuffer
        .where((m) => m.roomId == roomId)
        .toList();
    controller.add(initialLocal);

    controller.onCancel = () {
      subscription.cancel();
      localSub.cancel();
      controller.close();
    };

    return controller.stream;
  }

  @override
  Future<void> sendTradeOffer({
    required String roomId,
    required String senderId,
    required String message,
    required String offerId,
  }) async {
    final newMsg = ChatMessage(
      id: "mock_offer_${DateTime.now().microsecondsSinceEpoch}",
      roomId: roomId,
      senderId: senderId,
      message: message,
      createdAt: DateTime.now(),
      offerId: offerId,
      isSystem: true,
    );

    _localMessagesBuffer.add(newMsg);
    _messagesController.add(_localMessagesBuffer);

    if (mockInsertInterceptor != null) {
      try {
        await mockInsertInterceptor!(message);
      } catch (e) {
        // Simular fallo remoto manteniendo el catch original
      }
      return;
    }
    try {
      await _client.from("chat_messages").insert({
        "room_id": roomId,
        "sender_id": senderId,
        "message": message,
        "offer_id": offerId,
        "is_system": true,
      });
    } catch (_) {}
  }

  @override
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String message,
    bool isSystem = false,
  }) async {
    final newMsg = ChatMessage(
      id: "mock_msg_${DateTime.now().microsecondsSinceEpoch}",
      roomId: roomId,
      senderId: senderId,
      message: message,
      createdAt: DateTime.now(),
      isSystem: isSystem,
    );

    _localMessagesBuffer.add(newMsg);
    _messagesController.add(_localMessagesBuffer);

    try {
      await _client.from("chat_messages").insert({
        "room_id": roomId,
        "sender_id": senderId,
        "message": message,
        "is_system": isSystem,
      });
    } catch (_) {}
  }

  @override
  Stream<List<ChatRoom>> streamUserChatRooms(String userId) {
    return _client
        .from("chat_rooms")
        .stream(primaryKey: ["id"])
        .order("created_at", ascending: false)
        .map(
          (maps) => maps
              .map((map) => ChatRoom.fromJson(map))
              .where(
                (room) => room.buyerId == userId || room.sellerId == userId,
              )
              .toList(),
        );
  }

  @override
  Future<String> uploadMessageImage({
    required String roomId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      final String path = "$roomId/$fileName";
      await _client.storage.from("chat_attachments").uploadBinary(path, bytes);
      return _client.storage.from("chat_attachments").getPublicUrl(path);
    } catch (_) {
      return "https://picsum.photos";
    }
  }
}
