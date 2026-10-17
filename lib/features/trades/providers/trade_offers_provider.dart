import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/auth_service.dart';
import '../../../models/product.dart';
import '../domain/models/trade_offer.dart';
import '../repositories/trade_offer_repository_provider.dart';

class TradeOffersNotifier extends AsyncNotifier<List<TradeOffer>> {
  RealtimeChannel? _channel;

  @override
  Future<List<TradeOffer>> build() async {
    final userIdAsync = ref.watch(authUserIdProvider);
    final userId = userIdAsync.value;

    if (userId == null) {
      return [];
    }

    final repository = ref.watch(tradeOfferRepositoryProvider);
    final client = ref.watch(supabaseClientProvider);

    _initRealtimeSubscription(client, userId);

    return repository.getOffers(userId);
  }

  void _initRealtimeSubscription(SupabaseClient client, String userId) {
    _channel?.unsubscribe();

    _channel = client
        .channel('public:trade_offers:user_id=')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'trade_offers',
          callback: (payload) {
            ref.invalidateSelf();
          },
        );

    _channel?.subscribe();

    ref.onDispose(() {
      _channel?.unsubscribe();
    });
  }

  Future<void> sendOffer({
    required Product product,
    required String message,
    Product? offeredProduct,
  }) async {
    try {
      await ref
          .read(tradeOfferRepositoryProvider)
          .sendOffer(
            product: product,
            message: message,
            offeredProduct: offeredProduct,
          );

      // Forzar la invalidación inmediata para refrescar el estado del catálogo local
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> respondToOffer({
    required TradeOffer offer,
    required TradeOfferStatus status,
  }) async {
    try {
      await ref
          .read(tradeOfferRepositoryProvider)
          .updateStatus(offer: offer, status: status);

      // Invalidar el estado inmediatamente para sincronizar la UI tras la respuesta
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final tradeOffersProvider =
    AsyncNotifierProvider<TradeOffersNotifier, List<TradeOffer>>(
      TradeOffersNotifier.new,
    );
