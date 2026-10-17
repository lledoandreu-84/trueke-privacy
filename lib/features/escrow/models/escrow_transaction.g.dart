// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'escrow_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EscrowTransaction _$EscrowTransactionFromJson(Map<String, dynamic> json) =>
    _EscrowTransaction(
      id: json['id'] as String,
      tradeOfferId: json['tradeOfferId'] as String,
      buyerId: json['buyerId'] as String,
      sellerId: json['sellerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: $enumDecode(_$EscrowStatusEnumMap, json['status']),
      stripePaymentIntentId: json['stripePaymentIntentId'] as String,
      stripeTransferId: json['stripeTransferId'] as String?,
      trackingNumber: json['trackingNumber'] as String?,
      carrier: json['carrier'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$EscrowTransactionToJson(_EscrowTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tradeOfferId': instance.tradeOfferId,
      'buyerId': instance.buyerId,
      'sellerId': instance.sellerId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': _$EscrowStatusEnumMap[instance.status]!,
      'stripePaymentIntentId': instance.stripePaymentIntentId,
      'stripeTransferId': instance.stripeTransferId,
      'trackingNumber': instance.trackingNumber,
      'carrier': instance.carrier,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$EscrowStatusEnumMap = {
  EscrowStatus.pendingDeposit: 'pending_deposit',
  EscrowStatus.heldInEscrow: 'held_in_escrow',
  EscrowStatus.shipped: 'shipped',
  EscrowStatus.delivered: 'delivered',
  EscrowStatus.released: 'released',
  EscrowStatus.refunded: 'refunded',
};
