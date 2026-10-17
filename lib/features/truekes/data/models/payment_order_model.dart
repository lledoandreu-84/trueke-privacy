enum PaymentOrderStatus { initiated, processing, succeeded, failed }

class PaymentOrderModel {
  final String id;
  final String truekeId;
  final String userId;
  final double amount;
  final String currency;
  final PaymentOrderStatus status;
  final String? externalIntentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentOrderModel({
    required this.id,
    required this.truekeId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.status,
    this.externalIntentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) {
    return PaymentOrderModel(
      id: json['id'] as String,
      truekeId: json['trueke_id'] as String,
      userId: json['user_id'] as String,
      amount: double.parse(json['amount'].toString()),
      currency: json['currency'] as String,
      status: PaymentOrderStatus.values.firstWhere(
        (e) => e.name == json['status'] as String,
        orElse: () => PaymentOrderStatus.initiated,
      ),
      externalIntentId: json['external_intent_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trueke_id': truekeId,
      'user_id': userId,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'external_intent_id': externalIntentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
