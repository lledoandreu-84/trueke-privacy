// ignore_for_file: prefer_initializing_formals
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio encargado de interactuar con las funciones RPC geoespaciales de Supabase (PostGIS).
class PostgisLocationService {
  final SupabaseClient _supabase;

  PostgisLocationService({required SupabaseClient supabase})
    : _supabase = supabase;

  /// Invoca la función RPC de PostGIS para calcular la distancia exacta en metros entre dos puntos.
  Future<double> checkDistanceBetweenPoints({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) async {
    try {
      final response = await _supabase.rpc(
        'calculate_distance_meters',
        params: {
          'lat1': startLat,
          'lon1': startLon,
          'lat2': endLat,
          'lon2': endLon,
        },
      );

      if (response == null) {
        return double.infinity;
      }
      return (response as num).toDouble();
    } on PostgrestException catch (e) {
      throw Exception('Fallo geoespacial en RPC PostGIS: ${e.message}');
    } catch (_) {
      return double.infinity;
    }
  }
}
