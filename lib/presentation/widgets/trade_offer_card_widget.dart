import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/presentation/providers/trade_offer_provider.dart';

class TradeOfferCardWidget extends ConsumerWidget {
  final String offerId;
  final String title;
  final double targetLatitude;
  final double targetLongitude;

  const TradeOfferCardWidget({
    super.key,
    required this.offerId,
    required this.title,
    required this.targetLatitude,
    required this.targetLongitude,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tradeState = ref.watch(tradeOfferProvider(offerId));

    // Escucha fallos de red, distancia o permisos nativos para lanzar SnackBars controlados
    ref.listen<AsyncValue<void>>(tradeOfferProvider(offerId), (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          String errorMessage = 'Ocurrió un error inesperado';
          final errorStr = error.toString();

          if (errorStr.contains('PERMISO_GPS') ||
              errorStr.contains('LocationServiceDisabledException')) {
            errorMessage =
                '⚠️ Activa el GPS y acepta los permisos de ubicación para verificar la cercanía.';
          } else if (errorStr.contains('DISTANCE_EXCEEDED')) {
            errorMessage =
                '❌ Debéis estar a menos de 100 metros en Madrid para cerrar el intercambio.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    return Card(
      margin: const EdgeInsets.all(12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Control anti-doble pulsación: null deshabilita el botón si está cargando
                onPressed: tradeState.isLoading
                    ? null
                    : () => ref
                          .read(tradeOfferProvider(offerId).notifier)
                          .completeTrade(
                            targetLat: targetLatitude,
                            targetLng: targetLongitude,
                          ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  disabledBackgroundColor: Colors.teal.withValues(alpha: 0.3),
                ),
                child: tradeState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('🤝 Completar Trueke (Validar Ubicación)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
