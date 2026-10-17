import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/infrastructure/services/location_service_interface.dart';
import 'package:trueke/infrastructure/services/geolocator_location_service.dart';
import 'package:trueke/features/location/data/services/postgis_location_service.dart';

class TradeOfferNotifier extends AsyncNotifier<void> {
  final String offerId;
  final LocationServiceInterface _gpsService;
  final PostgisLocationService _postgisService;
  final SupabaseClient _supabase;

  TradeOfferNotifier(
    this.offerId, {
    LocationServiceInterface? gpsService,
    PostgisLocationService? postgisService,
    SupabaseClient? supabase,
  }) : _supabase = supabase ?? Supabase.instance.client,
       _gpsService = gpsService ?? const GeolocatorLocationService(),
       _postgisService =
           postgisService ??
           PostgisLocationService(
             supabase: supabase ?? Supabase.instance.client,
           );

  @override
  Future<void> build() async {
    return;
  }

  Future<void> completeTrade({
    required double targetLat,
    required double targetLng,
  }) async {
    state = const AsyncValue.loading();
    try {
      // 1. Obtener coordenadas actuales del hardware real
      final Position position = await _gpsService.getCurrentHardwareLocation();

      // 2. Calcular distancia exacta usando tu RPC de PostGIS
      final double distance = await _postgisService.checkDistanceBetweenPoints(
        startLat: position.latitude,
        startLon: position.longitude,
        endLat: targetLat,
        endLon: targetLng,
      );

      // 3. Validar filtro estricto de filosofía de Trueke (<100m en Madrid)
      if (distance > 100.0) {
        throw Exception('DISTANCE_EXCEEDED');
      }

      // 4. Muta el estado en base de datos. Las políticas RLS de trade_offers aseguran la firma
      await _supabase
          .from('trade_offers')
          .update({'status': 'completed'})
          .eq('id', offerId);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final tradeOfferProvider =
    AsyncNotifierProvider.family<TradeOfferNotifier, void, String>((arg) {
      return TradeOfferNotifier(arg);
    });
