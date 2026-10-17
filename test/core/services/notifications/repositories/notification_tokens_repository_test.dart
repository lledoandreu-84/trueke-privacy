import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/core/services/notifications/repositories/notification_tokens_repository.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

void main() {
  group(
    'SupabaseNotificationTokensRepository - Sincronizacion de Dispositivos',
    () {
      late FakeSupabaseClient fakeClient;

      setUp(() {
        fakeClient = FakeSupabaseClient();
      });

      test(
        'Debe mapear a JSON e invocar el interceptor correctamente al registrar un token activo',
        () async {
          Map<String, dynamic>? capturedPayload;

          final repository = SupabaseNotificationTokensRepository(
            fakeClient,
            mockSaveTokenInterceptor: (payload) async {
              capturedPayload = payload;
            },
          );

          await repository.saveToken(
            userId: 'usr_david_123',
            token: 'fcm_token_xyz_999',
          );

          expect(capturedPayload, isNotNull);
          expect(capturedPayload!['user_id'], equals('usr_david_123'));
          expect(capturedPayload!['token'], equals('fcm_token_xyz_999'));
          expect(capturedPayload!['device_type'], isA<String>());
          expect(capturedPayload!['updated_at'], isNotNull);
        },
      );

      test(
        'Debe propagar la excepcion controlada si la mutacion de eliminacion en el servidor falla',
        () async {
          final repository = SupabaseNotificationTokensRepository(
            fakeClient,
            mockDeleteTokenInterceptor: (token) async {
              throw Exception('Database mutation failure');
            },
          );

          expect(
            () => repository.deleteToken(token: 'fcm_token_expired'),
            throwsA(isA<Exception>()),
          );
        },
      );
    },
  );
}
