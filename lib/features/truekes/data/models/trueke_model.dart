enum TruekeStatus { pending, processing, completed, cancelled }

class TruekeModel {
  final String id;
  final String senderId;
  final String receiverId;
  final TruekeStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TruekeModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TruekeModel.fromJson(Map<String, dynamic> json) {
    return TruekeModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      status: TruekeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TruekeStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
