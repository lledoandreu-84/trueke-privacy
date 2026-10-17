class TransactionHistory {
  final String id;
  final String tradeOfferId;
  final String ownerId;
  final String traderId;
  final String productTitle;
  final String tradeType;
  final String status;
  final DateTime createdAt;

  const TransactionHistory({
    required this.id,
    required this.tradeOfferId,
    required this.ownerId,
    required this.traderId,
    required this.productTitle,
    required this.tradeType,
    required this.status,
    required this.createdAt,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    return TransactionHistory(
      id: json['id'] as String,
      tradeOfferId: json['trade_offer_id'] as String,
      ownerId: json['owner_id'] as String,
      traderId: json['trader_id'] as String,
      productTitle: json['product_title'] as String,
      tradeType: json['trade_type'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trade_offer_id': tradeOfferId,
      'owner_id': ownerId,
      'trader_id': traderId,
      'product_title': productTitle,
      'trade_type': tradeType,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
