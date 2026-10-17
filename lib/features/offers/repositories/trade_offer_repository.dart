import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/trade_offer.dart';

class TradeOfferRepository {
  final SupabaseClient _client;

  TradeOfferRepository(this._client);

  /// Recupera todas las ofertas donde el usuario sea emisor o receptor con tipado estricto
  Future<List<TradeOffer>> fetchOffersByUserId(String userId) async {
    final PostgrestList response = await _client
        .from('trade_offers')
        .select()
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false);

    return response.map((json) => TradeOffer.fromJson(json)).toList();
  }

  /// Crea e inserta una nueva propuesta de trueque directo blindando el payload
  Future<TradeOffer> createOffer({
    required String receiverId,
    required String senderProductId,
    required String receiverProductId,
    required double additionalCash,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Usuario no autenticado en el sistema');
    }

    final PostgrestMap response = await _client
        .from('trade_offers')
        .insert({
          'sender_id': currentUser.id,
          'receiver_id': receiverId,
          'sender_product_id': senderProductId,
          'receiver_product_id': receiverProductId,
          'additional_cash': additionalCash,
          'status': TradeOfferStatus.pending.name,
        })
        .select()
        .single();

    return TradeOffer.fromJson(response);
  }

  /// Modifica atómicamente el estado de una oferta específica
  Future<void> updateOfferStatus(
    String offerId,
    TradeOfferStatus status,
  ) async {
    await _client
        .from('trade_offers')
        .update({'status': status.name})
        .eq('id', offerId);
  }
}
