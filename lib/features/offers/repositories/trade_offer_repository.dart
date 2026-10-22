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
        .or('sender_id.eq.\$userId,receiver_id.eq.\$userId')
        .order('created_at', ascending: false);

    return response.map((json) => TradeOffer.fromJson(json)).toList();
  }

  /// Crea e inserta una nueva propuesta de trueque directo y su sala de chat asociada unificada
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

    // 1. Insertar la oferta de trueque
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

    final offer = TradeOffer.fromJson(response);

    // 2. Obtener el producto receptor para asociar la sala de chat única
    final productData = await _client
        .from('products')
        .select('id')
        .eq('id', receiverProductId)
        .maybeSingle();

    if (productData != null) {
      // 3. Crear o recuperar la sala de chat unificada entre comprador y vendedor
      final roomResponse = await _client
          .from('chat_rooms')
          .upsert({
            'product_id': receiverProductId,
            'buyer_id': currentUser.id,
            'seller_id': receiverId,
          }, onConflict: 'product_id,buyer_id,seller_id')
          .select()
          .single();

      final roomId = roomResponse['id'];

      // 4. Insertar mensaje inicial de la propuesta en la conversación compartida
      await _client.from('chat_messages').insert({
        'room_id': roomId,
        'sender_id': currentUser.id,
        'message': '¡Hola! Me interesa tu artículo y te propongo un trueque.',
        'is_system': false,
      });
    }

    return offer;
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
