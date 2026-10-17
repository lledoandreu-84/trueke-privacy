enum DisputeStatus { opened, underReview, resolved, closed }

class DisputeModel {
  final String id;
  final String truekeId;
  final String raisedBy;
  final String reason;
  final DisputeStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DisputeModel({
    required this.id,
    required this.truekeId,
    required this.raisedBy,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String;
    DisputeStatus parsedStatus;

    // Mapeo explícito y resiliente de estados de arbitraje para el linter y compilador
    if (rawStatus == 'under_review' || rawStatus == 'underReview') {
      parsedStatus = DisputeStatus.underReview;
    } else if (rawStatus == 'resolved') {
      parsedStatus = DisputeStatus.resolved;
    } else if (rawStatus == 'closed') {
      parsedStatus = DisputeStatus.closed;
    } else {
      parsedStatus = DisputeStatus.opened;
    }

    return DisputeModel(
      id: json['id'] as String,
      truekeId: json['trueke_id'] as String,
      raisedBy: json['raised_by'] as String,
      reason: json['reason'] as String,
      status: parsedStatus,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trueke_id': truekeId,
      'raised_by': raisedBy,
      'reason': reason,
      'status': status == DisputeStatus.underReview
          ? 'under_review'
          : status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
