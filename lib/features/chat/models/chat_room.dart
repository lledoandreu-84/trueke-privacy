import "package:flutter/foundation.dart";

@immutable
class ChatRoom {
  final String id;
  final String productId;
  final String sellerId;
  final String buyerId;
  final DateTime createdAt;

  const ChatRoom({
    required this.id,
    required this.productId,
    required this.sellerId,
    required this.buyerId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
    "seller_id": sellerId,
    "buyer_id": buyerId,
    "created_at": createdAt.toIso8601String(),
  };

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json["created_at"];
    final createdAt = rawCreatedAt is String
        ? DateTime.tryParse(rawCreatedAt) ?? DateTime.now()
        : DateTime.now();

    return ChatRoom(
      id: json["id"]?.toString() ?? "",
      productId: json["product_id"]?.toString() ?? "",
      sellerId: json["seller_id"]?.toString() ?? "",
      buyerId: json["buyer_id"]?.toString() ?? "",
      createdAt: createdAt,
    );
  }
}
