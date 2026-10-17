import "package:flutter/foundation.dart";

@immutable
class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String message;
  final DateTime createdAt;
  final String? offerId;
  final bool isSystem;
  final bool isRead;
  final bool isDelivered;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    this.offerId,
    this.isSystem = false,
    this.isRead = false,
    this.isDelivered = true,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "room_id": roomId,
    "sender_id": senderId,
    "message": message,
    "created_at": createdAt.toIso8601String(),
    "offer_id": offerId,
    "is_system": isSystem,
    "is_read": isRead,
    "is_delivered": isDelivered,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json["created_at"];
    final createdAt = rawCreatedAt is String
        ? DateTime.tryParse(rawCreatedAt) ?? DateTime.now()
        : DateTime.now();

    return ChatMessage(
      id: json["id"]?.toString() ?? "",
      roomId: json["room_id"]?.toString() ?? "",
      senderId: json["sender_id"]?.toString() ?? "",
      message: json["message"]?.toString() ?? "",
      createdAt: createdAt,
      offerId: json["offer_id"]?.toString(),
      isSystem: json["is_system"] is bool ? json["is_system"] : false,
      isRead: json["is_read"] is bool ? json["is_read"] : false,
      isDelivered: json["is_delivered"] is bool ? json["is_delivered"] : true,
    );
  }
}
