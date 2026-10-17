import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/core/supabase/supabase_client.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/features/transactions/models/notification_model.dart';
import 'package:trueke/core/services/notifications/domain/notifications_repository.dart';
import 'package:trueke/core/services/notifications/providers/notifications_history_provider.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockRealtimeChannel extends Mock implements RealtimeChannel {}

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

void main() {
  late MockSupabaseClient mockClient;
  late MockRealtimeChannel mockChannel;
  late MockNotificationsRepository mockRepository;
  ProviderContainer? container;

  final sampleNotifications = [
    NotificationModel(
      id: '1',
      userId: 'user_123',
      title: 'Test Title',
      message: 'Test Message',
      type: 'trade',
      isRead: false,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  setUpAll(() {
    registerFallbackValue(PostgresChangeEvent.all);
    registerFallbackValue(
      const PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: 'user_123',
      ),
    );
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockChannel = MockRealtimeChannel();
    mockRepository = MockNotificationsRepository();

    when(() => mockClient.channel(any())).thenReturn(mockChannel);
    when(
      () => mockChannel.onPostgresChanges(
        event: any(named: 'event'),
        schema: any(named: 'schema'),
        table: any(named: 'table'),
        filter: any(named: 'filter'),
        callback: any(named: 'callback'),
      ),
    ).thenReturn(mockChannel);
    when(() => mockChannel.subscribe()).thenReturn(mockChannel);
    when(
      () => mockChannel.unsubscribe(),
    ).thenAnswer((_) async => 'unsubscribed');

    when(
      () => mockRepository.fetchNotifications(userId: any(named: 'userId')),
    ).thenAnswer((_) async => sampleNotifications);
  });

  tearDown(() {
    container?.dispose();
  });

  test(
    'Debe inicializar con la lista del repositorio y suscribirse al canal Realtime',
    () async {
      container = ProviderContainer(
        overrides: [
          supabaseClientProvider.overrideWithValue(mockClient),
          authUserIdProvider.overrideWith((ref) => Stream.value('user_123')),
          notificationsRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      container!.listen(
        notificationsHistoryProvider,
        (_, _) {},
        fireImmediately: true,
      );

      await Future.delayed(Duration.zero);

      final result = await container!.read(notificationsHistoryProvider.future);

      expect(result, sampleNotifications);
      verify(
        () => mockClient.channel('public:notifications:user_id=eq.user_123'),
      ).called(1);
      verify(() => mockChannel.subscribe()).called(1);
    },
  );

  test(
    'Debe desuscribirse del canal Realtime cuando el proveedor sea destruido (onDispose)',
    () async {
      container = ProviderContainer(
        overrides: [
          supabaseClientProvider.overrideWithValue(mockClient),
          authUserIdProvider.overrideWith((ref) => Stream.value('user_123')),
          notificationsRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      container!.listen(
        notificationsHistoryProvider,
        (_, _) {},
        fireImmediately: true,
      );

      await Future.delayed(Duration.zero);
      await container!.read(notificationsHistoryProvider.future);

      container!.dispose();
      container = null;

      verify(() => mockChannel.unsubscribe()).called(1);
    },
  );
}
