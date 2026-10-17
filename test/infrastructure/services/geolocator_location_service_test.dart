import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trueke/infrastructure/services/geolocator_location_service.dart';

void main() {
  group('GeolocatorLocationService - Control de Localización por Hardware', () {
    test(
      'Debe retornar la posicion GPS exacta si el servicio esta activo y los permisos concedidos',
      () async {
        final mockPosition = Position(
          latitude: 40.416775,
          longitude: -3.703790,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 650.0,
          altitudeAccuracy: 1.0,
          heading: 0.0,
          headingAccuracy: 1.0,
          speed: 0.0,
          speedAccuracy: 1.0,
        );

        final service = GeolocatorLocationService(
          mockServiceEnabledInterceptor: () async => true,
          mockCheckPermissionInterceptor: () async =>
              LocationPermission.whileInUse,
          mockCurrentPositionInterceptor: () async => mockPosition,
        );

        final result = await service.getCurrentHardwareLocation();

        expect(result.latitude, equals(40.416775));
        expect(result.longitude, equals(-3.703790));
      },
    );

    test(
      'Debe lanzar LocationServiceDisabledException si el GPS general esta apagado',
      () async {
        final service = GeolocatorLocationService(
          mockServiceEnabledInterceptor: () async => false,
        );

        expect(
          () => service.getCurrentHardwareLocation(),
          throwsA(isA<LocationServiceDisabledException>()),
        );
      },
    );
  });
}
