import 'package:geolocator/geolocator.dart';

class LocationService {
  // Coordenadas de Fallback Estratégico por defecto: Madrid, España
  static const double _fallbackLat = 40.416775;
  static const double _fallbackLng = -3.703790;

  Position _getFallbackPosition() {
    return Position(
      latitude: _fallbackLat,
      longitude: _fallbackLng,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _getFallbackPosition();
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _getFallbackPosition();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _getFallbackPosition();
      }

      // Intento de captura de hardware real o simulado por el emulador
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(
        const Duration(seconds: 4),
        onTimeout: () => _getFallbackPosition(),
      );
    } catch (e) {
      // Inmunización nativa ante cualquier excepción de plataforma
      return _getFallbackPosition();
    }
  }
}
