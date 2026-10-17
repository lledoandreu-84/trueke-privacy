import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/product.dart';
import '../domain/models/trade_offer.dart';

class TradeOfferRepository {
  final SupabaseClient _client;
  static const _table = 'trade_offers';

  TradeOfferRepository(this._client);

  Future<List<TradeOffer>> getOffers(String userId) async {
    final response = await _client
        .from(_table)
        .select()
        .or('from_user_id.eq.$userId,to_user_id.eq.$userId')
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map(
          (item) => TradeOffer.fromJson(
            item as Map<String, dynamic>,
            currentUserId: userId,
          ),
        )
        .toList();
  }

  Future<void> sendOffer({
    required Product product,
    required String message,
    Product? offeredProduct,
  }) async {
    await _client.rpc<void>(
      'create_trade_offer',
      params: {
        'p_product_id': product.id,
        'p_message': message,
        'p_offered_product_id': offeredProduct?.id,
      },
    );
  }

  Future<TradeOffer> updateStatus({
    required TradeOffer offer,
    required TradeOfferStatus status,
  }) async {
    await _client.rpc<void>(
      'respond_to_trade_offer',
      params: {'p_offer_id': offer.id, 'p_status': status.name},
    );

    return offer.copyWith(status: status);
  }
}
