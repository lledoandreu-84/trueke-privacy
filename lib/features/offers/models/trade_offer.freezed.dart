// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trade_offer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TradeOffer {

 String get id;@JsonKey(name: 'sender_id') String get senderId;@JsonKey(name: 'receiver_id') String get receiverId;@JsonKey(name: 'sender_product_id') String get senderProductId;@JsonKey(name: 'receiver_product_id') String get receiverProductId;@JsonKey(name: 'additional_cash') double get additionalCash; TradeOfferStatus get status;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of TradeOffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TradeOfferCopyWith<TradeOffer> get copyWith => _$TradeOfferCopyWithImpl<TradeOffer>(this as TradeOffer, _$identity);

  /// Serializes this TradeOffer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TradeOffer&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.senderProductId, senderProductId) || other.senderProductId == senderProductId)&&(identical(other.receiverProductId, receiverProductId) || other.receiverProductId == receiverProductId)&&(identical(other.additionalCash, additionalCash) || other.additionalCash == additionalCash)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,receiverId,senderProductId,receiverProductId,additionalCash,status,createdAt,updatedAt);

@override
String toString() {
  return 'TradeOffer(id: $id, senderId: $senderId, receiverId: $receiverId, senderProductId: $senderProductId, receiverProductId: $receiverProductId, additionalCash: $additionalCash, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TradeOfferCopyWith<$Res>  {
  factory $TradeOfferCopyWith(TradeOffer value, $Res Function(TradeOffer) _then) = _$TradeOfferCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'sender_id') String senderId,@JsonKey(name: 'receiver_id') String receiverId,@JsonKey(name: 'sender_product_id') String senderProductId,@JsonKey(name: 'receiver_product_id') String receiverProductId,@JsonKey(name: 'additional_cash') double additionalCash, TradeOfferStatus status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class _$TradeOfferCopyWithImpl<$Res>
    implements $TradeOfferCopyWith<$Res> {
  _$TradeOfferCopyWithImpl(this._self, this._then);

  final TradeOffer _self;
  final $Res Function(TradeOffer) _then;

/// Create a copy of TradeOffer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderId = null,Object? receiverId = null,Object? senderProductId = null,Object? receiverProductId = null,Object? additionalCash = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(TradeOffer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,senderProductId: null == senderProductId ? _self.senderProductId : senderProductId // ignore: cast_nullable_to_non_nullable
as String,receiverProductId: null == receiverProductId ? _self.receiverProductId : receiverProductId // ignore: cast_nullable_to_non_nullable
as String,additionalCash: null == additionalCash ? _self.additionalCash : additionalCash // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TradeOfferStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TradeOffer].
extension TradeOfferPatterns on TradeOffer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TradeOffer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TradeOffer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TradeOffer value)  $default,){
final _that = this;
switch (_that) {
case _TradeOffer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TradeOffer value)?  $default,){
final _that = this;
switch (_that) {
case _TradeOffer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'sender_id')  String senderId, @JsonKey(name: 'receiver_id')  String receiverId, @JsonKey(name: 'sender_product_id')  String senderProductId, @JsonKey(name: 'receiver_product_id')  String receiverProductId, @JsonKey(name: 'additional_cash')  double additionalCash,  TradeOfferStatus status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TradeOffer() when $default != null:
return $default(_that.id,_that.senderId,_that.receiverId,_that.senderProductId,_that.receiverProductId,_that.additionalCash,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'sender_id')  String senderId, @JsonKey(name: 'receiver_id')  String receiverId, @JsonKey(name: 'sender_product_id')  String senderProductId, @JsonKey(name: 'receiver_product_id')  String receiverProductId, @JsonKey(name: 'additional_cash')  double additionalCash,  TradeOfferStatus status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TradeOffer():
return $default(_that.id,_that.senderId,_that.receiverId,_that.senderProductId,_that.receiverProductId,_that.additionalCash,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'sender_id')  String senderId, @JsonKey(name: 'receiver_id')  String receiverId, @JsonKey(name: 'sender_product_id')  String senderProductId, @JsonKey(name: 'receiver_product_id')  String receiverProductId, @JsonKey(name: 'additional_cash')  double additionalCash,  TradeOfferStatus status, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TradeOffer() when $default != null:
return $default(_that.id,_that.senderId,_that.receiverId,_that.senderProductId,_that.receiverProductId,_that.additionalCash,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TradeOffer implements TradeOffer {
  const _TradeOffer({required this.id, @JsonKey(name: 'sender_id') required this.senderId, @JsonKey(name: 'receiver_id') required this.receiverId, @JsonKey(name: 'sender_product_id') required this.senderProductId, @JsonKey(name: 'receiver_product_id') required this.receiverProductId, @JsonKey(name: 'additional_cash') this.additionalCash = 0.0, required this.status, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _TradeOffer.fromJson(Map<String, dynamic> json) => _$TradeOfferFromJson(json);

@override final  String id;
@override@JsonKey(name: 'sender_id') final  String senderId;
@override@JsonKey(name: 'receiver_id') final  String receiverId;
@override@JsonKey(name: 'sender_product_id') final  String senderProductId;
@override@JsonKey(name: 'receiver_product_id') final  String receiverProductId;
@override@JsonKey(name: 'additional_cash') final  double additionalCash;
@override final  TradeOfferStatus status;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of TradeOffer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TradeOfferCopyWith<_TradeOffer> get copyWith => __$TradeOfferCopyWithImpl<_TradeOffer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TradeOfferToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TradeOffer&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.senderProductId, senderProductId) || other.senderProductId == senderProductId)&&(identical(other.receiverProductId, receiverProductId) || other.receiverProductId == receiverProductId)&&(identical(other.additionalCash, additionalCash) || other.additionalCash == additionalCash)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,receiverId,senderProductId,receiverProductId,additionalCash,status,createdAt,updatedAt);

@override
String toString() {
  return 'TradeOffer(id: $id, senderId: $senderId, receiverId: $receiverId, senderProductId: $senderProductId, receiverProductId: $receiverProductId, additionalCash: $additionalCash, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TradeOfferCopyWith<$Res> implements $TradeOfferCopyWith<$Res> {
  factory _$TradeOfferCopyWith(_TradeOffer value, $Res Function(_TradeOffer) _then) = __$TradeOfferCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'sender_id') String senderId,@JsonKey(name: 'receiver_id') String receiverId,@JsonKey(name: 'sender_product_id') String senderProductId,@JsonKey(name: 'receiver_product_id') String receiverProductId,@JsonKey(name: 'additional_cash') double additionalCash, TradeOfferStatus status,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});




}
/// @nodoc
class __$TradeOfferCopyWithImpl<$Res>
    implements _$TradeOfferCopyWith<$Res> {
  __$TradeOfferCopyWithImpl(this._self, this._then);

  final _TradeOffer _self;
  final $Res Function(_TradeOffer) _then;

/// Create a copy of TradeOffer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderId = null,Object? receiverId = null,Object? senderProductId = null,Object? receiverProductId = null,Object? additionalCash = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_TradeOffer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,senderProductId: null == senderProductId ? _self.senderProductId : senderProductId // ignore: cast_nullable_to_non_nullable
as String,receiverProductId: null == receiverProductId ? _self.receiverProductId : receiverProductId // ignore: cast_nullable_to_non_nullable
as String,additionalCash: null == additionalCash ? _self.additionalCash : additionalCash // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TradeOfferStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
