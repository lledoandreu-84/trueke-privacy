// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserReview {

 String get id;@JsonKey(name: 'trueke_id') String get truekeId;@JsonKey(name: 'reviewer_id') String get reviewerId;@JsonKey(name: 'reviewed_id') String get reviewedId; double get rating; String get comment;@JsonKey(name: 'created_at') DateTime get createdAt; String get reviewerName; String get reviewerAvatar;
/// Create a copy of UserReview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserReviewCopyWith<UserReview> get copyWith => _$UserReviewCopyWithImpl<UserReview>(this as UserReview, _$identity);

  /// Serializes this UserReview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserReview&&(identical(other.id, id) || other.id == id)&&(identical(other.truekeId, truekeId) || other.truekeId == truekeId)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId)&&(identical(other.reviewedId, reviewedId) || other.reviewedId == reviewedId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reviewerName, reviewerName) || other.reviewerName == reviewerName)&&(identical(other.reviewerAvatar, reviewerAvatar) || other.reviewerAvatar == reviewerAvatar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,truekeId,reviewerId,reviewedId,rating,comment,createdAt,reviewerName,reviewerAvatar);

@override
String toString() {
  return 'UserReview(id: $id, truekeId: $truekeId, reviewerId: $reviewerId, reviewedId: $reviewedId, rating: $rating, comment: $comment, createdAt: $createdAt, reviewerName: $reviewerName, reviewerAvatar: $reviewerAvatar)';
}


}

/// @nodoc
abstract mixin class $UserReviewCopyWith<$Res>  {
  factory $UserReviewCopyWith(UserReview value, $Res Function(UserReview) _then) = _$UserReviewCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'trueke_id') String truekeId,@JsonKey(name: 'reviewer_id') String reviewerId,@JsonKey(name: 'reviewed_id') String reviewedId, double rating, String comment,@JsonKey(name: 'created_at') DateTime createdAt, String reviewerName, String reviewerAvatar
});




}
/// @nodoc
class _$UserReviewCopyWithImpl<$Res>
    implements $UserReviewCopyWith<$Res> {
  _$UserReviewCopyWithImpl(this._self, this._then);

  final UserReview _self;
  final $Res Function(UserReview) _then;

/// Create a copy of UserReview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? truekeId = null,Object? reviewerId = null,Object? reviewedId = null,Object? rating = null,Object? comment = null,Object? createdAt = null,Object? reviewerName = null,Object? reviewerAvatar = null,}) {
  return _then(UserReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,truekeId: null == truekeId ? _self.truekeId : truekeId // ignore: cast_nullable_to_non_nullable
as String,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,reviewedId: null == reviewedId ? _self.reviewedId : reviewedId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reviewerName: null == reviewerName ? _self.reviewerName : reviewerName // ignore: cast_nullable_to_non_nullable
as String,reviewerAvatar: null == reviewerAvatar ? _self.reviewerAvatar : reviewerAvatar // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserReview].
extension UserReviewPatterns on UserReview {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserReview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserReview() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserReview value)  $default,){
final _that = this;
switch (_that) {
case _UserReview():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserReview value)?  $default,){
final _that = this;
switch (_that) {
case _UserReview() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'trueke_id')  String truekeId, @JsonKey(name: 'reviewer_id')  String reviewerId, @JsonKey(name: 'reviewed_id')  String reviewedId,  double rating,  String comment, @JsonKey(name: 'created_at')  DateTime createdAt,  String reviewerName,  String reviewerAvatar)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserReview() when $default != null:
return $default(_that.id,_that.truekeId,_that.reviewerId,_that.reviewedId,_that.rating,_that.comment,_that.createdAt,_that.reviewerName,_that.reviewerAvatar);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'trueke_id')  String truekeId, @JsonKey(name: 'reviewer_id')  String reviewerId, @JsonKey(name: 'reviewed_id')  String reviewedId,  double rating,  String comment, @JsonKey(name: 'created_at')  DateTime createdAt,  String reviewerName,  String reviewerAvatar)  $default,) {final _that = this;
switch (_that) {
case _UserReview():
return $default(_that.id,_that.truekeId,_that.reviewerId,_that.reviewedId,_that.rating,_that.comment,_that.createdAt,_that.reviewerName,_that.reviewerAvatar);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'trueke_id')  String truekeId, @JsonKey(name: 'reviewer_id')  String reviewerId, @JsonKey(name: 'reviewed_id')  String reviewedId,  double rating,  String comment, @JsonKey(name: 'created_at')  DateTime createdAt,  String reviewerName,  String reviewerAvatar)?  $default,) {final _that = this;
switch (_that) {
case _UserReview() when $default != null:
return $default(_that.id,_that.truekeId,_that.reviewerId,_that.reviewedId,_that.rating,_that.comment,_that.createdAt,_that.reviewerName,_that.reviewerAvatar);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserReview implements UserReview {
  const _UserReview({required this.id, @JsonKey(name: 'trueke_id') required this.truekeId, @JsonKey(name: 'reviewer_id') required this.reviewerId, @JsonKey(name: 'reviewed_id') required this.reviewedId, required this.rating, required this.comment, @JsonKey(name: 'created_at') required this.createdAt, this.reviewerName = 'Usuario', this.reviewerAvatar = ''});
  factory _UserReview.fromJson(Map<String, dynamic> json) => _$UserReviewFromJson(json);

@override final  String id;
@override@JsonKey(name: 'trueke_id') final  String truekeId;
@override@JsonKey(name: 'reviewer_id') final  String reviewerId;
@override@JsonKey(name: 'reviewed_id') final  String reviewedId;
@override final  double rating;
@override final  String comment;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey() final  String reviewerName;
@override@JsonKey() final  String reviewerAvatar;

/// Create a copy of UserReview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserReviewCopyWith<_UserReview> get copyWith => __$UserReviewCopyWithImpl<_UserReview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserReviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserReview&&(identical(other.id, id) || other.id == id)&&(identical(other.truekeId, truekeId) || other.truekeId == truekeId)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId)&&(identical(other.reviewedId, reviewedId) || other.reviewedId == reviewedId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.reviewerName, reviewerName) || other.reviewerName == reviewerName)&&(identical(other.reviewerAvatar, reviewerAvatar) || other.reviewerAvatar == reviewerAvatar));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,truekeId,reviewerId,reviewedId,rating,comment,createdAt,reviewerName,reviewerAvatar);

@override
String toString() {
  return 'UserReview(id: $id, truekeId: $truekeId, reviewerId: $reviewerId, reviewedId: $reviewedId, rating: $rating, comment: $comment, createdAt: $createdAt, reviewerName: $reviewerName, reviewerAvatar: $reviewerAvatar)';
}


}

/// @nodoc
abstract mixin class _$UserReviewCopyWith<$Res> implements $UserReviewCopyWith<$Res> {
  factory _$UserReviewCopyWith(_UserReview value, $Res Function(_UserReview) _then) = __$UserReviewCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'trueke_id') String truekeId,@JsonKey(name: 'reviewer_id') String reviewerId,@JsonKey(name: 'reviewed_id') String reviewedId, double rating, String comment,@JsonKey(name: 'created_at') DateTime createdAt, String reviewerName, String reviewerAvatar
});




}
/// @nodoc
class __$UserReviewCopyWithImpl<$Res>
    implements _$UserReviewCopyWith<$Res> {
  __$UserReviewCopyWithImpl(this._self, this._then);

  final _UserReview _self;
  final $Res Function(_UserReview) _then;

/// Create a copy of UserReview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? truekeId = null,Object? reviewerId = null,Object? reviewedId = null,Object? rating = null,Object? comment = null,Object? createdAt = null,Object? reviewerName = null,Object? reviewerAvatar = null,}) {
  return _then(_UserReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,truekeId: null == truekeId ? _self.truekeId : truekeId // ignore: cast_nullable_to_non_nullable
as String,reviewerId: null == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String,reviewedId: null == reviewedId ? _self.reviewedId : reviewedId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reviewerName: null == reviewerName ? _self.reviewerName : reviewerName // ignore: cast_nullable_to_non_nullable
as String,reviewerAvatar: null == reviewerAvatar ? _self.reviewerAvatar : reviewerAvatar // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
