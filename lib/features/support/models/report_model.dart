class ReportModel {
  final String id;
  final String reporterId;
  final String targetId; // ID del producto o usuario reportado
  final String targetType; // 'product' o 'user'
  final String reason;
  final String description;
  final String status; // 'pending', 'under_review', 'resolved'
  final DateTime createdAt;

  const ReportModel({
    required this.id,
    required this.reporterId,
    required this.targetId,
    required this.targetType,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      targetId: json['target_id'] as String,
      targetType: json['target_type'] as String,
      reason: json['reason'] as String,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'target_id': targetId,
      'target_type': targetType,
      'reason': reason,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
