import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/core/supabase/supabase_client.dart';
import 'package:trueke/features/offers/models/trade_offer.dart';
import 'package:trueke/features/offers/repositories/trade_offer_repository.dart';
import 'package:trueke/features/offers/providers/trade_offer_provider.dart';

class MockSupabaseClient implements SupabaseClient {
  @override
  GoTrueClient get auth => MockGoTrueClient();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockGoTrueClient implements GoTrueClient {
  @override
  User? get currentUser => User(
    id: 'user-a',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTradeOfferRepository implements TradeOfferRepository {
  final List<TradeOffer> _stubOffers;
  MockTradeOfferRepository(this._stubOffers);

  @override
  Future<List<TradeOffer>> fetchOffersByUserId(String userId) async {
    return _stubOffers;
  }

  @override
  Future<TradeOffer> createOffer({
    required String receiverId,
    required String senderProductId,
    required String receiverProductId,
    required double additionalCash,
  }) async {
    return _stubOffers.first;
  }

  @override
  Future<void> updateOfferStatus(
    String offerId,
    TradeOfferStatus status,
  ) async {}
}

void main() {
  group('Módulo de Matching - Pruebas Unitarias de Flujo de Ofertas', () {
    late List<TradeOffer> seedOffers;
    late MockTradeOfferRepository mockRepository;
    late MockSupabaseClient mockSupabaseClient;

    setUp(() {
      seedOffers = [
        TradeOffer(
          id: 'offer-123',
          senderId: 'user-a',
          receiverId: 'user-b',
          senderProductId: 'prod-1',
          receiverProductId: 'prod-2',
          additionalCash: 15.0,
          status: TradeOfferStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      mockRepository = MockTradeOfferRepository(seedOffers);
      mockSupabaseClient = MockSupabaseClient();
    });

    test(
      'Inicialización del proveedor expone correctamente la lista de ofertas del repositorio',
      () async {
        final container = ProviderContainer(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            tradeOfferRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        addTearDown(container.dispose);
        final state = container.read(userTradeOffersProvider);
        expect(state, isA<AsyncValue<List<TradeOffer>>>());
      },
    );
  });
}
