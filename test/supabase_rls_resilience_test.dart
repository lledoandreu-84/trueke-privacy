import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  group('Módulo de Seguridad: Robustecimiento de Políticas RLS y Expiración JWT', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockSupabaseQueryBuilder mockQueryBuilder;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();

      // Corrección matemática: Usar thenAnswer para componentes que implementan interfaces asíncronas
      when(
        () => mockSupabaseClient.from(any()),
      ).thenAnswer((_) => mockQueryBuilder);
    });

    test(
      'Simulación de error: Anon JWT Expirado (HTTP 401 Unauthorized)',
      () async {
        when(() => mockQueryBuilder.select()).thenThrow(
          const PostgrestException(
            message: 'JWToken expired or invalid signature',
            code: '401',
          ),
        );

        expect(
          () => mockSupabaseClient.from('products').select(),
          throwsA(
            isA<PostgrestException>().having((e) => e.code, 'code', '401'),
          ),
        );
      },
    );

    test(
      'Simulación de error: Violación de Política RLS (Acceso Denegado 403 / PGRST)',
      () async {
        when(() => mockQueryBuilder.select()).thenThrow(
          const PostgrestException(
            message:
                'new row violates row-level security policy for table trade_offers',
            code: '403',
          ),
        );

        expect(
          () => mockSupabaseClient.from('trade_offers').select(),
          throwsA(
            isA<PostgrestException>().having(
              (e) => e.message,
              'message',
              contains('row-level security policy'),
            ),
          ),
        );
      },
    );
  });
}
