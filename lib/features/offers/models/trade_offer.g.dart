// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade_offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TradeOffer _$TradeOfferFromJson(Map<String, dynamic> json) => _TradeOffer(
  id: json['id'] as String,
  senderId: json['sender_id'] as String,
  receiverId: json['receiver_id'] as String,
  senderProductId: json['sender_product_id'] as String,
  receiverProductId: json['receiver_product_id'] as String,
  additionalCash: (json['additional_cash'] as num?)?.toDouble() ?? 0.0,
  status: $enumDecode(_$TradeOfferStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$TradeOfferToJson(_TradeOffer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender_id': instance.senderId,
      'receiver_id': instance.receiverId,
      'sender_product_id': instance.senderProductId,
      'receiver_product_id': instance.receiverProductId,
      'additional_cash': instance.additionalCash,
      'status': _$TradeOfferStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$TradeOfferStatusEnumMap = {
  TradeOfferStatus.pending: 'pending',
  TradeOfferStatus.accepted: 'accepted',
  TradeOfferStatus.declined: 'declined',
  TradeOfferStatus.canceled: 'canceled',
};
