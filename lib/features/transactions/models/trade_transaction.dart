class TradeTransaction {
  final String id;
  final String senderId;
  final String receiverId;
  final String offeredProductId;
  final String requestedProductId;
  final String status; // 'pending', 'accepted', 'rejected', 'completed'
  final DateTime createdAt;

  const TradeTransaction({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.offeredProductId,
    required this.requestedProductId,
    required this.status,
    required this.createdAt,
  });

  bool get isExpired {
    if (status != 'pending') {
      return false;
    }
    final duration = DateTime.now().difference(createdAt);
    return duration.inHours >= 48;
  }

  String get effectiveStatus {
    if (isExpired) {
      return 'expired';
    }
    return status;
  }

  factory TradeTransaction.fromJson(Map<String, dynamic> json) {
    return TradeTransaction(
      id: json['id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      receiverId: json['receiver_id'] as String? ?? '',
      offeredProductId: json['offered_product_id'] as String? ?? '',
      requestedProductId: json['requested_product_id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'offered_product_id': offeredProductId,
      'requested_product_id': requestedProductId,
      'status': status,
    };
  }

  TradeTransaction copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? offeredProductId,
    String? requestedProductId,
    String? status,
    DateTime? createdAt,
  }) {
    return TradeTransaction(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      offeredProductId: offeredProductId ?? this.offeredProductId,
      requestedProductId: requestedProductId ?? this.requestedProductId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
