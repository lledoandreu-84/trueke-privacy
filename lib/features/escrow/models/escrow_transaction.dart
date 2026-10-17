import 'package:freezed_annotation/freezed_annotation.dart';

part 'escrow_transaction.freezed.dart';
part 'escrow_transaction.g.dart';

enum EscrowStatus {
  @JsonValue('pending_deposit')
  pendingDeposit,
  @JsonValue('held_in_escrow')
  heldInEscrow,
  @JsonValue('shipped')
  shipped,
  @JsonValue('delivered')
  delivered,
  @JsonValue('released')
  released,
  @JsonValue('refunded')
  refunded,
}

@freezed
abstract class EscrowTransaction with _$EscrowTransaction {
  const factory EscrowTransaction({
    required String id,
    required String tradeOfferId,
    required String buyerId,
    required String sellerId,
    required double amount,
    required String currency,
    required EscrowStatus status,
    required String stripePaymentIntentId,
    String? stripeTransferId,
    String? trackingNumber,
    String? carrier,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _EscrowTransaction;

  factory EscrowTransaction.fromJson(Map<String, dynamic> json) =>
      _$EscrowTransactionFromJson(json);
}
