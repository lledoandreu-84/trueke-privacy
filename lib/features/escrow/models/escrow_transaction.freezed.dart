// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'escrow_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EscrowTransaction {

 String get id; String get tradeOfferId; String get buyerId; String get sellerId; double get amount; String get currency; EscrowStatus get status; String get stripePaymentIntentId; String? get stripeTransferId; String? get trackingNumber; String? get carrier; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of EscrowTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EscrowTransactionCopyWith<EscrowTransaction> get copyWith => _$EscrowTransactionCopyWithImpl<EscrowTransaction>(this as EscrowTransaction, _$identity);

  /// Serializes this EscrowTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EscrowTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.tradeOfferId, tradeOfferId) || other.tradeOfferId == tradeOfferId)&&(identical(other.buyerId, buyerId) || other.buyerId == buyerId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.stripePaymentIntentId, stripePaymentIntentId) || other.stripePaymentIntentId == stripePaymentIntentId)&&(identical(other.stripeTransferId, stripeTransferId) || other.stripeTransferId == stripeTransferId)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&(identical(other.carrier, carrier) || other.carrier == carrier)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tradeOfferId,buyerId,sellerId,amount,currency,status,stripePaymentIntentId,stripeTransferId,trackingNumber,carrier,createdAt,updatedAt);

@override
String toString() {
  return 'EscrowTransaction(id: $id, tradeOfferId: $tradeOfferId, buyerId: $buyerId, sellerId: $sellerId, amount: $amount, currency: $currency, status: $status, stripePaymentIntentId: $stripePaymentIntentId, stripeTransferId: $stripeTransferId, trackingNumber: $trackingNumber, carrier: $carrier, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $EscrowTransactionCopyWith<$Res>  {
  factory $EscrowTransactionCopyWith(EscrowTransaction value, $Res Function(EscrowTransaction) _then) = _$EscrowTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String tradeOfferId, String buyerId, String sellerId, double amount, String currency, EscrowStatus status, String stripePaymentIntentId, String? stripeTransferId, String? trackingNumber, String? carrier, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$EscrowTransactionCopyWithImpl<$Res>
    implements $EscrowTransactionCopyWith<$Res> {
  _$EscrowTransactionCopyWithImpl(this._self, this._then);

  final EscrowTransaction _self;
  final $Res Function(EscrowTransaction) _then;

/// Create a copy of EscrowTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tradeOfferId = null,Object? buyerId = null,Object? sellerId = null,Object? amount = null,Object? currency = null,Object? status = null,Object? stripePaymentIntentId = null,Object? stripeTransferId = freezed,Object? trackingNumber = freezed,Object? carrier = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(EscrowTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tradeOfferId: null == tradeOfferId ? _self.tradeOfferId : tradeOfferId // ignore: cast_nullable_to_non_nullable
as String,buyerId: null == buyerId ? _self.buyerId : buyerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EscrowStatus,stripePaymentIntentId: null == stripePaymentIntentId ? _self.stripePaymentIntentId : stripePaymentIntentId // ignore: cast_nullable_to_non_nullable
as String,stripeTransferId: freezed == stripeTransferId ? _self.stripeTransferId : stripeTransferId // ignore: cast_nullable_to_non_nullable
as String?,trackingNumber: freezed == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String?,carrier: freezed == carrier ? _self.carrier : carrier // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EscrowTransaction].
extension EscrowTransactionPatterns on EscrowTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EscrowTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EscrowTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EscrowTransaction value)  $default,){
final _that = this;
switch (_that) {
case _EscrowTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EscrowTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _EscrowTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tradeOfferId,  String buyerId,  String sellerId,  double amount,  String currency,  EscrowStatus status,  String stripePaymentIntentId,  String? stripeTransferId,  String? trackingNumber,  String? carrier,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EscrowTransaction() when $default != null:
return $default(_that.id,_that.tradeOfferId,_that.buyerId,_that.sellerId,_that.amount,_that.currency,_that.status,_that.stripePaymentIntentId,_that.stripeTransferId,_that.trackingNumber,_that.carrier,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tradeOfferId,  String buyerId,  String sellerId,  double amount,  String currency,  EscrowStatus status,  String stripePaymentIntentId,  String? stripeTransferId,  String? trackingNumber,  String? carrier,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _EscrowTransaction():
return $default(_that.id,_that.tradeOfferId,_that.buyerId,_that.sellerId,_that.amount,_that.currency,_that.status,_that.stripePaymentIntentId,_that.stripeTransferId,_that.trackingNumber,_that.carrier,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tradeOfferId,  String buyerId,  String sellerId,  double amount,  String currency,  EscrowStatus status,  String stripePaymentIntentId,  String? stripeTransferId,  String? trackingNumber,  String? carrier,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _EscrowTransaction() when $default != null:
return $default(_that.id,_that.tradeOfferId,_that.buyerId,_that.sellerId,_that.amount,_that.currency,_that.status,_that.stripePaymentIntentId,_that.stripeTransferId,_that.trackingNumber,_that.carrier,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EscrowTransaction implements EscrowTransaction {
  const _EscrowTransaction({required this.id, required this.tradeOfferId, required this.buyerId, required this.sellerId, required this.amount, required this.currency, required this.status, required this.stripePaymentIntentId, this.stripeTransferId, this.trackingNumber, this.carrier, this.createdAt, this.updatedAt});
  factory _EscrowTransaction.fromJson(Map<String, dynamic> json) => _$EscrowTransactionFromJson(json);

@override final  String id;
@override final  String tradeOfferId;
@override final  String buyerId;
@override final  String sellerId;
@override final  double amount;
@override final  String currency;
@override final  EscrowStatus status;
@override final  String stripePaymentIntentId;
@override final  String? stripeTransferId;
@override final  String? trackingNumber;
@override final  String? carrier;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of EscrowTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EscrowTransactionCopyWith<_EscrowTransaction> get copyWith => __$EscrowTransactionCopyWithImpl<_EscrowTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EscrowTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EscrowTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.tradeOfferId, tradeOfferId) || other.tradeOfferId == tradeOfferId)&&(identical(other.buyerId, buyerId) || other.buyerId == buyerId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.stripePaymentIntentId, stripePaymentIntentId) || other.stripePaymentIntentId == stripePaymentIntentId)&&(identical(other.stripeTransferId, stripeTransferId) || other.stripeTransferId == stripeTransferId)&&(identical(other.trackingNumber, trackingNumber) || other.trackingNumber == trackingNumber)&&(identical(other.carrier, carrier) || other.carrier == carrier)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tradeOfferId,buyerId,sellerId,amount,currency,status,stripePaymentIntentId,stripeTransferId,trackingNumber,carrier,createdAt,updatedAt);

@override
String toString() {
  return 'EscrowTransaction(id: $id, tradeOfferId: $tradeOfferId, buyerId: $buyerId, sellerId: $sellerId, amount: $amount, currency: $currency, status: $status, stripePaymentIntentId: $stripePaymentIntentId, stripeTransferId: $stripeTransferId, trackingNumber: $trackingNumber, carrier: $carrier, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$EscrowTransactionCopyWith<$Res> implements $EscrowTransactionCopyWith<$Res> {
  factory _$EscrowTransactionCopyWith(_EscrowTransaction value, $Res Function(_EscrowTransaction) _then) = __$EscrowTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String tradeOfferId, String buyerId, String sellerId, double amount, String currency, EscrowStatus status, String stripePaymentIntentId, String? stripeTransferId, String? trackingNumber, String? carrier, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$EscrowTransactionCopyWithImpl<$Res>
    implements _$EscrowTransactionCopyWith<$Res> {
  __$EscrowTransactionCopyWithImpl(this._self, this._then);

  final _EscrowTransaction _self;
  final $Res Function(_EscrowTransaction) _then;

/// Create a copy of EscrowTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tradeOfferId = null,Object? buyerId = null,Object? sellerId = null,Object? amount = null,Object? currency = null,Object? status = null,Object? stripePaymentIntentId = null,Object? stripeTransferId = freezed,Object? trackingNumber = freezed,Object? carrier = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_EscrowTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tradeOfferId: null == tradeOfferId ? _self.tradeOfferId : tradeOfferId // ignore: cast_nullable_to_non_nullable
as String,buyerId: null == buyerId ? _self.buyerId : buyerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EscrowStatus,stripePaymentIntentId: null == stripePaymentIntentId ? _self.stripePaymentIntentId : stripePaymentIntentId // ignore: cast_nullable_to_non_nullable
as String,stripeTransferId: freezed == stripeTransferId ? _self.stripeTransferId : stripeTransferId // ignore: cast_nullable_to_non_nullable
as String?,trackingNumber: freezed == trackingNumber ? _self.trackingNumber : trackingNumber // ignore: cast_nullable_to_non_nullable
as String?,carrier: freezed == carrier ? _self.carrier : carrier // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
