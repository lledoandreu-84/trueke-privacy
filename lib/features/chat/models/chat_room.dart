class ChatRoom {
  final int unreadCount;
  final String id;
  final String productId;
  final String buyerId;
  final String sellerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatRoom({
    required this.id,
    this.unreadCount = 0,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      unreadCount: json['unread_count'] as int? ?? 0,
        id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      buyerId: json['buyer_id'] as String? ?? '',
      sellerId: json['seller_id'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? DateTime.now().toIso8601String()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'buyer_id': buyerId,
        'seller_id': sellerId,
      };
}

typedef Conversation = ChatRoom;
