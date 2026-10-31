class ChatRoom {
  final int unreadBuyer;
  final int unreadSeller;
  final String id;
  final String productId;
  final String buyerId;
  final String sellerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatRoom({
    required this.id,
    this.unreadBuyer = 0,
    this.unreadSeller = 0,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.createdAt,
    required this.updatedAt,
  });

  int getUnreadCountForUser(String userId) {
    if (userId == buyerId) return unreadBuyer;
    if (userId == sellerId) return unreadSeller;
    return 0;
  }

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      unreadBuyer: json['unread_buyer'] as int? ?? 0,
      unreadSeller: json['unread_seller'] as int? ?? 0,
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