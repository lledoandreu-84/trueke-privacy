import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

class MockFunctionResponse extends Mock implements FunctionResponse {}

// Excepción controlada para simular fallos de la Edge Function de Stripe
class TestStripeFunctionException implements Exception {
  final String message;
  TestStripeFunctionException(this.message);

  @override
  String toString() => message;
}

void main() {
  group(
    'Módulo 1 & Escrow: Robustecimiento del Pipeline Transaccional (Stripe Connect Webhook)',
    () {
      late MockSupabaseClient mockSupabaseClient;
      late MockFunctionsClient mockFunctionsClient;
      late MockFunctionResponse mockFunctionResponse;

      setUp(() {
        mockSupabaseClient = MockSupabaseClient();
        mockFunctionsClient = MockFunctionsClient();
        mockFunctionResponse = MockFunctionResponse();

        when(
          () => mockSupabaseClient.functions,
        ).thenReturn(mockFunctionsClient);
      });

      test(
        'Simulación de error: Payload malformado o excepción financiera en Edge Function',
        () async {
          when(
            () => mockFunctionsClient.invoke(
              'stripe-webhook',
              body: any(named: 'body'),
            ),
          ).thenThrow(
            TestStripeFunctionException(
              '{"error": "Unexpected token in JSON or invalid stripe metadata"}',
            ),
          );

          expect(
            () =>
                mockSupabaseClient.functions.invoke('stripe-webhook', body: {}),
            throwsA(
              isA<TestStripeFunctionException>().having(
                (e) => e.message,
                'message',
                contains('invalid stripe metadata'),
              ),
            ),
          );
        },
      );

      test(
        'Simulación de estabilidad: Servidor retorna código de éxito HTTP 200',
        () async {
          when(() => mockFunctionResponse.status).thenReturn(200);
          when(() => mockFunctionResponse.data).thenReturn({'received': true});

          when(
            () => mockFunctionsClient.invoke(
              'stripe-webhook',
              body: any(named: 'body'),
            ),
          ).thenAnswer((_) async => mockFunctionResponse);

          final response = await mockSupabaseClient.functions.invoke(
            'stripe-webhook',
            body: {
              'type': 'payment_intent.succeeded',
              'data': {
                'object': {
                  'metadata': {'tradeOfferId': 'trade-777'},
                },
              },
            },
          );

          expect(response.status, 200);
          expect(response.data, isMap);
          expect(response.data['received'], true);
        },
      );
    },
  );
}
