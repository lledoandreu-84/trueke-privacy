import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_offer.freezed.dart';
part 'trade_offer.g.dart';

enum TradeOfferStatus { pending, accepted, declined, canceled }

@freezed
abstract class TradeOffer with _$TradeOffer {
  const factory TradeOffer({
    required String id,
    @JsonKey(name: 'sender_id') required String senderId,
    @JsonKey(name: 'receiver_id') required String receiverId,
    @JsonKey(name: 'sender_product_id') required String senderProductId,
    @JsonKey(name: 'receiver_product_id') required String receiverProductId,
    @JsonKey(name: 'additional_cash') @Default(0.0) double additionalCash,
    required TradeOfferStatus status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _TradeOffer;

  factory TradeOffer.fromJson(Map<String, dynamic> json) =>
      _$TradeOfferFromJson(json);
}
