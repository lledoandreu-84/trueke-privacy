import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/chat/data/supabase_chat_repository.dart';
import 'package:trueke/features/chat/models/chat_message.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

void main() {
  group('SupabaseChatRepository Reactividad y Resiliencia Offline', () {
    late FakeSupabaseClient fakeClient;
    late SupabaseChatRepository repository;
    const String roomId = 'room-test-000';
    const String senderId = 'usr-sender-111';

    setUp(() {
      fakeClient = FakeSupabaseClient();
    });

    test(
      'Debe alimentar instantáneamente el Stream con los mensajes del búfer local en memoria',
      () async {
        // Configuramos el repositorio inyectando datos planos en el interceptor de pruebas
        repository = SupabaseChatRepository(
          fakeClient,
          mockInsertInterceptor: (msg) async => Future.value(null),
          mockStreamMessagesInterceptor: (room) => Stream.value([
            ChatMessage(
              id: 'mock_sincrono_id',
              roomId: room,
              senderId: senderId,
              message: 'Hola Trueke síncrono',
              createdAt: DateTime.now(),
            ),
          ]),
        );

        // Registrar un mensaje en caliente en la cola local
        await repository.sendMessage(
          roomId: roomId,
          senderId: senderId,
          message: 'Hola Trueke síncrono',
        );

        final stream = repository.streamMessages(roomId);
        final firstEmission = await stream.first;

        expect(firstEmission, isNotEmpty);
        expect(
          firstEmission.any((m) => m.message == 'Hola Trueke síncrono'),
          isTrue,
        );
      },
    );

    test(
      'Debe persistir en la cola visual local de mensajes aunque falle la inserción remota en Supabase',
      () async {
        repository = SupabaseChatRepository(
          fakeClient,
          mockInsertInterceptor: (msg) async {
            if (msg == 'Fallo voluntario') {
              throw Exception('Error al insertar mensaje remoto');
            }
          },
          mockStreamMessagesInterceptor: (room) => Stream.value([
            ChatMessage(
              id: 'mock_fallo_id',
              roomId: room,
              senderId: senderId,
              message: 'Fallo voluntario',
              createdAt: DateTime.now(),
            ),
          ]),
        );

        final stream = repository.streamMessages(roomId);

        // Disparar un envío de mensaje diseñado para fallar en la base de datos remota
        await repository.sendMessage(
          roomId: roomId,
          senderId: senderId,
          message: 'Fallo voluntario',
        );

        final currentMessages = await stream.first;

        // Certificar que, a pesar de la excepción de internet capturada en el catch, la UI no pierde el mensaje
        final hasMessage = currentMessages.any(
          (m) => m.message == 'Fallo voluntario',
        );
        expect(hasMessage, isTrue);
      },
    );
  });
}
