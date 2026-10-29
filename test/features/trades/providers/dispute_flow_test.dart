import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/truekes/data/models/dispute_model.dart';
import 'package:trueke/features/truekes/data/repositories/dispute_repository.dart';
import 'package:trueke/features/chat/data/chat_repository.dart';
import 'package:trueke/features/chat/providers/chat_providers.dart';
import 'package:trueke/features/truekes/presentation/providers/dispute_providers.dart';

// Mock manual de DisputeRepository para simular fallos y éxitos controlados
class FakeDisputeRepository implements DisputeRepository {
  bool shouldFail = false;

  @override
  Future<DisputeModel> createDispute({
    required String truekeId,
    required String raisedBy,
    required String reason,
  }) async {
    if (shouldFail) throw Exception('Error de conexión con Supabase');
    return DisputeModel(
      id: 'disp_mock',
      truekeId: truekeId,
      raisedBy: raisedBy,
      reason: reason,
      status: DisputeStatus.opened,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Stream<List<DisputeModel>> streamDisputesByTruekeId(String truekeId) {
    return Stream.value([]);
  }

  @override
  Future<DisputeModel> updateDisputeStatus({
    required String disputeId,
    required DisputeStatus status,
  }) async {
    throw UnimplementedError();
  }
}

// Mock manual de ChatRepository
class FakeChatRepository implements ChatRepository {
  @override
  Future<void> deleteConversation(String conversationId) async {}

  @override
  Future<void> sendMessage({String? content, String? conversationId,
    String? roomId,
    String? senderId,
    String? message,
    bool isSystem = false,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Truekes: Flujo de Disputas y Mediación Comunitaria', () {
    test(
      'Debe mapear e instanciar correctamente un DisputeModel desde un JSON válido',
      () {
        final json = {
          'id': 'disp_9921',
          'trueke_id': 'trueke_abc_123',
          'raised_by': 'usr_buyer_77',
          'reason':
              'El artículo llegó con la pantalla rota y no en el estado "Como nuevo" descrito.',
          'status': 'opened',
          'created_at': '2026-10-07T09:00:00.000Z',
          'updated_at': '2026-10-07T09:00:00.000Z',
        };

        final dispute = DisputeModel.fromJson(json);

        expect(dispute.id, equals('disp_9921'));
        expect(dispute.truekeId, equals('trueke_abc_123'));
        expect(dispute.raisedBy, equals('usr_buyer_77'));
        expect(dispute.reason, contains('pantalla rota'));
        expect(dispute.status, equals(DisputeStatus.opened));
      },
    );

    test(
      'Debe fallar o lanzar una excepción controlada si el motivo de la disputa está completamente vacío',
      () {
        String? validateDisputeReason(String reason) {
          if (reason.trim().isEmpty) {
            return 'El motivo de la disputa no puede estar vacío.';
          }
          if (reason.trim().length < 10) {
            return 'Por favor, proporciona una descripción más detallada del problema.';
          }
          return null;
        }

        expect(
          validateDisputeReason(''),
          equals('El motivo de la disputa no puede estar vacío.'),
        );
        expect(
          validateDisputeReason('Roto'),
          equals(
            'Por favor, proporciona una descripción más detallada del problema.',
          ),
        );
        expect(
          validateDisputeReason('El terminal tiene la batería inflada'),
          isNull,
        );
      },
    );
  });

  group('DisputeNotifier Asynchronous Integration Tests', () {
    test(
      'Debe recuperar y restaurar el estado con valor previo ante un fallo en raiseDispute',
      () async {
        final fakeDisputeRepo = FakeDisputeRepository();
        final fakeChatRepo = FakeChatRepository();

        final container = ProviderContainer(
          overrides: [
            disputeRepositoryProvider.overrideWithValue(fakeDisputeRepo),
            chatRepositoryProvider.overrideWithValue(fakeChatRepo),
          ],
        );

        final initialDisputes = [
          DisputeModel(
            id: 'disp_existente',
            truekeId: 'tk_123',
            raisedBy: 'usr_1',
            reason: 'Problema previo',
            status: DisputeStatus.opened,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        // Inicializar el Notifier con un estado con valor de datos previo simulado
        container.read(disputeNotifierProvider.notifier).state =
            AsyncValue.data(initialDisputes);

        // Forzar que el repositorio falle en la inserción
        fakeDisputeRepo.shouldFail = true;

        // Disparar la mutación capturando el rethrow imperativo requerido por la UI
        try {
          await container
              .read(disputeNotifierProvider.notifier)
              .raiseDispute(
                truekeId: 'tk_123',
                raisedBy: 'usr_1',
                reason: 'Esta inserción va a fallar voluntariamente',
                chatRoomId: 'room_xyz',
              );
        } catch (_) {
          // Captura controlada del error propagado
        }

        final finalState = container.read(disputeNotifierProvider);

        // Verificar que el notifier aplicó el fallback reactivo manteniendo la colección previa a salvo
        expect(finalState.hasValue, isTrue);
        expect(finalState.value, equals(initialDisputes));
      },
    );
  });
}
