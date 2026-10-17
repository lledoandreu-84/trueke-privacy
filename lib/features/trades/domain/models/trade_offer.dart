enum TradeOfferStatus { sent, accepted, rejected }

class TradeOffer {
  final String id;
  final String productId;
  final String productTitle;
  final String message;
  final DateTime createdAt;
  final TradeOfferStatus status;
  final String? fromUserId;
  final String? toUserId;
  final String? conversationId;
  final String? offeredProductId;
  final String? offeredProductTitle;
  final bool isIncoming;

  const TradeOffer({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.message,
    required this.createdAt,
    this.status = TradeOfferStatus.sent,
    this.fromUserId,
    this.toUserId,
    this.conversationId,
    this.offeredProductId,
    this.offeredProductTitle,
    this.isIncoming = false,
  });

  bool get isPending => status == TradeOfferStatus.sent;

  TradeOffer copyWith({TradeOfferStatus? status}) {
    return TradeOffer(
      id: id,
      productId: productId,
      productTitle: productTitle,
      message: message,
      createdAt: createdAt,
      status: status ?? this.status,
      fromUserId: fromUserId,
      toUserId: toUserId,
      conversationId: conversationId,
      offeredProductId: offeredProductId,
      offeredProductTitle: offeredProductTitle,
      isIncoming: isIncoming,
    );
  }

  factory TradeOffer.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final fromUserId =
        json['from_user_id'] as String? ?? json['fromUserId'] as String?;
    final createdAtRaw =
        json['created_at'] as String? ?? json['createdAt'] as String;
    final statusName = json['status'] as String? ?? TradeOfferStatus.sent.name;

    return TradeOffer(
      id: json['id'] as String,
      productId: json['product_id'] as String? ?? json['productId'] as String,
      productTitle:
          json['product_title'] as String? ??
          json['productTitle'] as String? ??
          'Producto',
      message: json['message'] as String? ?? '',
      createdAt: DateTime.parse(createdAtRaw),
      status: TradeOfferStatus.values.byName(statusName),
      fromUserId: fromUserId,
      toUserId: json['to_user_id'] as String? ?? json['toUserId'] as String?,
      conversationId:
          json['conversation_id'] as String? ??
          json['conversationId'] as String?,
      offeredProductId:
          json['offered_product_id'] as String? ??
          json['offeredProductId'] as String?,
      offeredProductTitle:
          json['offered_product_title'] as String? ??
          json['offeredProductTitle'] as String?,
      isIncoming: currentUserId != null && fromUserId != currentUserId,
    );
  }
}
