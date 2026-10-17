class Review {
  final String id;
  final String truekeId;
  final String reviewerId;
  final String reviewedId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.truekeId,
    required this.reviewerId,
    required this.reviewedId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'trueke_id': truekeId,
    'reviewer_id': reviewerId,
    'reviewed_id': reviewedId,
    'rating': rating,
    'comment': comment,
    'created_at': createdAt.toIso8601String(),
  };

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      truekeId: json['trueke_id']?.toString() ?? '',
      reviewerId: json['reviewer_id']?.toString() ?? '',
      reviewedId: json['reviewed_id']?.toString() ?? '',
      rating: json['rating'] is num ? (json['rating'] as num).toInt() : 5,
      comment: json['comment']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
    );
  }
}
