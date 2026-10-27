class ChatRoom {
  final String id;
  final String productId;
  final String buyerId;
  final String sellerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatRoom({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      buyerId: json['buyer_id'] as String,
      sellerId: json['seller_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'buyer_id': buyerId,
        'seller_id': sellerId,
      };
}

typedef Conversation = ChatRoom;
