import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../models/trade_offer.dart';
import '../repositories/trade_offer_repository.dart';

/// Proveedor clásico del Repositorio de Ofertas
final tradeOfferRepositoryProvider = Provider<TradeOfferRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TradeOfferRepository(client);
});

/// Notificador de Estado Asíncrono Puro bajo la especificación Riverpod 3.x
class UserTradeOffersNotifier extends AsyncNotifier<List<TradeOffer>> {
  @override
  FutureOr<List<TradeOffer>> build() async {
    return _fetchCurrentOffers();
  }

  Future<List<TradeOffer>> _fetchCurrentOffers() async {
    final currentUser = ref.watch(supabaseClientProvider).auth.currentUser;
    if (currentUser == null) {
      return [];
    }
    final repo = ref.read(tradeOfferRepositoryProvider);
    return repo.fetchOffersByUserId(currentUser.id);
  }

  /// Propone una nueva oferta e invalida de forma segura el flujo reactivo
  Future<void> proposeNewOffer({
    required String receiverId,
    required String senderProductId,
    required String receiverProductId,
    required double additionalCash,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(tradeOfferRepositoryProvider);
      await repo.createOffer(
        receiverId: receiverId,
        senderProductId: senderProductId,
        receiverProductId: receiverProductId,
        additionalCash: additionalCash,
      );
      return _fetchCurrentOffers();
    });
  }

  /// Resuelve el flujo de aceptación o rechazo mutando el estado local
  Future<void> resolveOffer(String offerId, TradeOfferStatus newStatus) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(tradeOfferRepositoryProvider);
      await repo.updateOfferStatus(offerId, newStatus);
      return _fetchCurrentOffers();
    });
  }
}

/// Exposición del proveedor utilizando la directiva unificada autoDispose
final userTradeOffersProvider =
    AsyncNotifierProvider.autoDispose<
      UserTradeOffersNotifier,
      List<TradeOffer>
    >(() {
      return UserTradeOffersNotifier();
    });
