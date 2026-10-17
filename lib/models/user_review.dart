import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_review.freezed.dart';
part 'user_review.g.dart';

@freezed
abstract class UserReview with _$UserReview {
  const factory UserReview({
    required String id,
    @JsonKey(name: 'trueke_id') required String truekeId,
    @JsonKey(name: 'reviewer_id') required String reviewerId,
    @JsonKey(name: 'reviewed_id') required String reviewedId,
    required double rating,
    required String comment,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default('Usuario') String reviewerName,
    @Default('') String reviewerAvatar,
  }) = _UserReview;

  factory UserReview.fromJson(Map<String, dynamic> json) =>
      _$UserReviewFromJson(json);
}
