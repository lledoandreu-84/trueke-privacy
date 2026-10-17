import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/core/supabase/supabase_client.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/features/trades/domain/models/trade_offer.dart';
import 'package:trueke/features/trades/repositories/trade_offer_repository.dart';
import 'package:trueke/features/trades/repositories/trade_offer_repository_provider.dart';
import 'package:trueke/features/trades/providers/trade_offers_provider.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockRealtimeChannel extends Mock implements RealtimeChannel {}

class MockTradeOfferRepository extends Mock implements TradeOfferRepository {}

void main() {
  late MockSupabaseClient mockClient;
  late MockRealtimeChannel mockChannel;
  late MockTradeOfferRepository mockRepository;
  ProviderContainer? container;

  final sampleOffers = <TradeOffer>[
    TradeOffer(
      id: 'offer_001',
      productId: 'prod_123',
      productTitle: 'Tabla de Surf',
      message: '¿Te interesa mi neopreno?',
      createdAt: DateTime(2026, 1, 1),
      status: TradeOfferStatus.sent,
      fromUserId: 'user_789',
      toUserId: 'user_123',
      isIncoming: true,
    ),
  ];

  setUpAll(() {
    registerFallbackValue(PostgresChangeEvent.all);
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockChannel = MockRealtimeChannel();
    mockRepository = MockTradeOfferRepository();

    when(() => mockClient.channel(any())).thenReturn(mockChannel);
    when(
      () => mockChannel.onPostgresChanges(
        event: any(named: 'event'),
        schema: any(named: 'schema'),
        table: any(named: 'table'),
        callback: any(named: 'callback'),
      ),
    ).thenReturn(mockChannel);
    when(() => mockChannel.subscribe()).thenReturn(mockChannel);
    when(
      () => mockChannel.unsubscribe(),
    ).thenAnswer((_) async => 'unsubscribed');

    when(
      () => mockRepository.getOffers(any()),
    ).thenAnswer((_) async => sampleOffers);
  });

  tearDown(() {
    container?.dispose();
  });

  test(
    'Debe inicializar TradeOffersNotifier con la lista del repositorio y suscribirse al canal',
    () async {
      container = ProviderContainer(
        overrides: [
          supabaseClientProvider.overrideWithValue(mockClient),
          authUserIdProvider.overrideWith((ref) => Stream.value('user_123')),
          tradeOfferRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      container!.listen(tradeOffersProvider, (_, _) {}, fireImmediately: true);

      await Future.delayed(Duration.zero);

      final result = await container!.read(tradeOffersProvider.future);

      expect(result, sampleOffers);
      verify(() => mockClient.channel(any())).called(1);
      verify(() => mockChannel.subscribe()).called(1);
    },
  );

  test(
    'Debe desuscribirse del canal Realtime cuando el proveedor se destruya (onDispose)',
    () async {
      container = ProviderContainer(
        overrides: [
          supabaseClientProvider.overrideWithValue(mockClient),
          authUserIdProvider.overrideWith((ref) => Stream.value('user_123')),
          tradeOfferRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      container!.listen(tradeOffersProvider, (_, _) {}, fireImmediately: true);

      await Future.delayed(Duration.zero);
      await container!.read(tradeOffersProvider.future);

      container!.dispose();
      container = null;

      verify(() => mockChannel.unsubscribe()).called(1);
    },
  );
}
