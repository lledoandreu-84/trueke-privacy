enum EscrowStatus { held, released, refunded }

class EscrowModel {
  final String id;
  final String truekeId;
  final double amount;
  final EscrowStatus status;
  final DateTime createdAt;

  const EscrowModel({
    required this.id,
    required this.truekeId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory EscrowModel.fromJson(Map<String, dynamic> json) {
    return EscrowModel(
      id: json['id'] as String,
      truekeId: json['trueke_id'] as String,
      amount: double.parse(json['amount'].toString()),
      status: EscrowStatus.values.firstWhere(
        (e) => e.name == json['status'] as String,
        orElse: () => EscrowStatus.held,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trueke_id': truekeId,
      'amount': amount,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
