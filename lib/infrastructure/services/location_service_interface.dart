import 'package:geolocator/geolocator.dart';

abstract class LocationServiceInterface {
  /// Obtiene la posición GPS actual del hardware del dispositivo.
  /// Puede lanzar excepciones específicas de permisos o servicio deshabilitado.
  Future<Position> getCurrentHardwareLocation();
}
