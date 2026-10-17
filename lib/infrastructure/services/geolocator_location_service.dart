import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:trueke/infrastructure/services/location_service_interface.dart';

class GeolocatorLocationService implements LocationServiceInterface {
  // Callbacks opcionales exclusivos para interceptar y simular respuestas de hardware en suites de pruebas
  final Future<bool> Function()? mockServiceEnabledInterceptor;
  final Future<LocationPermission> Function()? mockCheckPermissionInterceptor;
  final Future<LocationPermission> Function()? mockRequestPermissionInterceptor;
  final Future<Position> Function()? mockCurrentPositionInterceptor;

  const GeolocatorLocationService({
    this.mockServiceEnabledInterceptor,
    this.mockCheckPermissionInterceptor,
    this.mockRequestPermissionInterceptor,
    this.mockCurrentPositionInterceptor,
  });

  @override
  Future<Position> getCurrentHardwareLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    if (mockServiceEnabledInterceptor != null) {
      serviceEnabled = await mockServiceEnabledInterceptor!();
    } else {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    }

    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    if (mockCheckPermissionInterceptor != null) {
      permission = await mockCheckPermissionInterceptor!();
    } else {
      permission = await Geolocator.checkPermission();
    }

    if (permission == LocationPermission.denied) {
      if (mockRequestPermissionInterceptor != null) {
        permission = await mockRequestPermissionInterceptor!();
      } else {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Permisos de localización denegados por el usuario.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permisos de localización denegados de forma permanente en los ajustes del dispositivo.',
      );
    }

    if (mockCurrentPositionInterceptor != null) {
      return await mockCurrentPositionInterceptor!();
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } on TimeoutException {
      // Degradación graciosa si el GPS de alta precisión tarda en fijar satélites
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return lastKnown;
      }
      throw Exception(
        'Tiempo de espera agotado al adquirir coordenadas de alta precisión.',
      );
    }
  }
}
