import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/escrow/providers/escrow_notifier.dart';
import 'package:trueke/features/escrow/providers/escrow_state.dart';
import 'package:trueke/features/escrow/repositories/escrow_repository.dart';
import 'package:trueke/features/escrow/models/escrow_transaction.dart';
import 'package:trueke/features/chat/data/chat_repository.dart';
import 'package:trueke/features/chat/providers/chat_providers.dart';
import 'package:trueke/features/chat/models/chat_room.dart';

// Mocks de infraestructura con herencia limpia de Fake
class FakeEscrowRepository extends Fake implements EscrowRepository {
  bool releaseFundsCalled = false;
  bool throwError = false;

  @override
  Future<EscrowTransaction> releaseEscrowFunds({
    required String escrowId,
  }) async {
    if (throwError) throw Exception('Database timeout');
    releaseFundsCalled = true;
    return EscrowTransaction(
      id: escrowId,
      tradeOfferId: 'to_123',
      buyerId: 'b_1',
      sellerId: 's_1',
      amount: 50.0,
      currency: 'EUR',
      status: EscrowStatus.released, // Sincronizado con el enum de produccion
      stripePaymentIntentId:
          'pi_test_mock_123', // Parametro nominal requerido por Freezed
      createdAt: DateTime.now(),
    );
  }
}

class FakeChatRoom extends Fake implements ChatRoom {
  @override
  String get id => 'room_abc_999';
}

class FakeChatRepository extends Fake implements ChatRepository {
  bool messageSent = false;

  @override
  Future<ChatRoom> getOrCreateChatRoom({
    required String productId,
    required String buyerId,
    required String sellerId,
  }) async {
    return FakeChatRoom();
  }

  @override
  Future<void> sendMessage({String? content, String? conversationId,
    String? roomId,
    String? senderId,
    String? message,
    bool isSystem = false,
  }) async {
    messageSent = true;
  }
}

void main() {
  group('EscrowNotifier - Pruebas Unitarias de Control de Custodia', () {
    late ProviderContainer container;
    late FakeEscrowRepository fakeEscrowRepo;
    late FakeChatRepository fakeChatRepo;

    setUp(() {
      fakeEscrowRepo = FakeEscrowRepository();
      fakeChatRepo = FakeChatRepository();
      container = ProviderContainer(
        overrides: [
          escrowRepositoryProvider.overrideWithValue(fakeEscrowRepo),
          chatRepositoryProvider.overrideWithValue(fakeChatRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'Debe transicionar a EscrowLoaded y disparar mensaje automatizado en chat al liberar fondos con exito',
      () async {
        final notifier = container.read(
          escrowNotifierProvider('to_123').notifier,
        );

        await notifier.releaseEscrowFunds(escrowId: 'esc_999');

        final state = container.read(escrowNotifierProvider('to_123'));
        expect(state, isA<EscrowLoaded>());
        expect(fakeEscrowRepo.releaseFundsCalled, isTrue);
        expect(fakeChatRepo.messageSent, isTrue);
      },
    );

    test(
      'Debe mutar el estado a EscrowError si la liberacion de fondos remota en base de datos falla',
      () async {
        fakeEscrowRepo.throwError = true;
        final notifier = container.read(
          escrowNotifierProvider('to_123').notifier,
        );

        await notifier.releaseEscrowFunds(escrowId: 'esc_999');

        final state = container.read(escrowNotifierProvider('to_123'));
        expect(state, isA<EscrowError>());
        expect((state as EscrowError).message, contains('Error al procesar'));
      },
    );
  });
}
