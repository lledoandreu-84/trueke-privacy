import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/core/supabase/supabase_client.dart';
import 'package:trueke/features/offers/models/trade_offer.dart';
import 'package:trueke/features/offers/presentation/screens/trade_offers_screen.dart';
import 'package:trueke/features/offers/repositories/trade_offer_repository.dart';
import 'package:trueke/features/offers/providers/trade_offer_provider.dart';

class MockUISupabaseClient implements SupabaseClient {
  @override
  GoTrueClient get auth => MockUIGoTrueClient();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUIGoTrueClient implements GoTrueClient {
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

class MockUIOffersRepository implements TradeOfferRepository {
  final List<TradeOffer> _stubOffers;
  MockUIOffersRepository(this._stubOffers);
  @override
  Future<List<TradeOffer>> fetchOffersByUserId(String userId) async =>
      _stubOffers;
  @override
  Future<TradeOffer> createOffer({
    required String receiverId,
    required String senderProductId,
    required String receiverProductId,
    required double additionalCash,
  }) async => _stubOffers.first;
  @override
  Future<void> updateOfferStatus(
    String offerId,
    TradeOfferStatus status,
  ) async {}
}

void main() {
  group('Módulo de Matching - Pruebas de Interfaz de Usuario', () {
    testWidgets(
      'TradeOffersScreen se monta y renderiza correctamente en el árbol visual',
      (WidgetTester tester) async {
        final mockRepo = MockUIOffersRepository([]);
        final mockSupabase = MockUISupabaseClient();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              supabaseClientProvider.overrideWithValue(mockSupabase),
              tradeOfferRepositoryProvider.overrideWithValue(mockRepo),
            ],
            child: const MaterialApp(home: TradeOffersScreen()),
          ),
        );
        await tester.pump();
        expect(find.byType(TradeOffersScreen), findsOneWidget);
      },
    );
  });
}
