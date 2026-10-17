import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/infrastructure/services/location_service_interface.dart';
import 'package:trueke/features/location/data/services/postgis_location_service.dart';
import 'package:trueke/presentation/providers/trade_offer_provider.dart';

class MockLocationServiceError implements LocationServiceInterface {
  final String errorType;
  MockLocationServiceError(this.errorType);

  @override
  Future<Position> getCurrentHardwareLocation() async {
    throw Exception(errorType);
  }
}

class StubPostgisLocationService implements PostgisLocationService {
  @override
  Future<double> checkDistanceBetweenPoints({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) async {
    return 0.0;
  }
}

class FakeSupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'Debe capturar error de permiso denegado y mutar el estado a AsyncError',
    () async {
      // 1. Inicializamos el contenedor de Riverpod para gestionar el ciclo de vida del estado
      final container = ProviderContainer(
        overrides: [
          // Sobrescribimos el proveedor .family para inyectar los mocks controlados de forma limpia
          tradeOfferProvider('offer_123').overrideWith(
            () => TradeOfferNotifier(
              'offer_123',
              gpsService: MockLocationServiceError('PERMISO_GPS_DENEGADO'),
              postgisService: StubPostgisLocationService(),
              supabase: FakeSupabaseClient(),
            ),
          ),
        ],
      );

      addTearDown(container.dispose);

      // 2. Leemos el proveedor por primera vez para asegurar su correcta inicialización (ejecuta el build())
      final _ = container.read(tradeOfferProvider('offer_123').notifier);

      // 3. Obtenemos el notifier inicializado y ejecutamos la acción
      final notifier = container.read(tradeOfferProvider('offer_123').notifier);
      await notifier.completeTrade(targetLat: 40.4167, targetLng: -3.7037);

      // 4. Verificamos el estado final directamente desde el contenedor de Riverpod
      final finalState = container.read(tradeOfferProvider('offer_123'));

      expect(finalState.error != null, true);
      expect(finalState.error.toString(), contains('PERMISO_GPS_DENEGADO'));
    },
  );
}
