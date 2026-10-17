import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class MockSupabaseClient extends Mock implements SupabaseClient {}

// Mock explícito que incorpora dart:async para resolver la firma de Postgrest
class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<dynamic> {
  final Future<dynamic> _futureResponse;

  MockPostgrestFilterBuilder(this._futureResponse);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(dynamic) onValue, {
    Function? onError,
  }) {
    return _futureResponse.then(onValue, onError: onError);
  }
}

void main() {
  group('Módulo 2: Geolocalización Nativa y Resiliencia PostGIS', () {
    late MockSupabaseClient mockSupabaseClient;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
    });

    test(
      'Simulación RPC PostGIS: Retorno Exitoso de Productos en el Radio de Madrid',
      () async {
        final mockProductsInRadius = [
          {
            'id': 'prod-100',
            'title': 'Bicicleta de Montaña',
            'geo_location': 'POINT(-3.703790 40.416775)',
            'distancia_metros': 1250.5,
          },
        ];

        final builderWithSuccess = MockPostgrestFilterBuilder(
          Future.value(mockProductsInRadius),
        );

        when(
          () => mockSupabaseClient.rpc(
            'search_products_by_radius',
            params: any(named: 'params'),
          ),
        ).thenAnswer((_) => builderWithSuccess);

        final response = await mockSupabaseClient.rpc(
          'search_products_by_radius',
          params: {'radius_km': 5.0, 'lat': 40.416775, 'lng': -3.703790},
        );

        expect(response, isList);
        expect((response as List).first['id'], 'prod-100');
      },
    );

    test(
      'Simulación de error: Fallo de Permisos de Ubicación / Excepción del Dispositivo',
      () async {
        const mockException = PostgrestException(
          message:
              'User denied location permissions or database coordinate mapping failed',
          code: 'PGRST',
        );

        final builderWithError = MockPostgrestFilterBuilder(
          Future.error(mockException),
        );

        when(
          () => mockSupabaseClient.rpc(
            'search_products_by_radius',
            params: any(named: 'params'),
          ),
        ).thenAnswer((_) => builderWithError);

        expect(
          () => mockSupabaseClient.rpc('search_products_by_radius', params: {}),
          throwsA(
            isA<PostgrestException>().having(
              (e) => e.message,
              'message',
              contains('location permissions'),
            ),
          ),
        );
      },
    );
  });
}
