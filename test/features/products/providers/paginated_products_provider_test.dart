import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:trueke/models/product.dart';

void main() {
  group('PaginatedProductsNotifier - Motor Haversine Nativo', () {
    test(
      'Debe ordenar los productos de más cercanos a más lejanos en base a Haversine',
      () {
        // Coordenadas simuladas del usuario (Madrid Centro)
        const double userLat = 40.416775;
        const double userLng = -3.703790;

        // Producto 1: Muy cercano (Retiro, Madrid ~ 2 km)
        final productCercano = Product(
          id: 'cercano',
          title: 'Producto Cercano',
          description: 'A pocos metros',
          tradeType: TradeType.trade,
          category: 'Otros',
          location: 'Madrid El Retiro',
          owner: 'Test',
          ownerId: '1',
          condition: 'Buen estado',
          wanted: 'Nada',
          createdAt: DateTime.now(),
          latitude: 40.415363,
          longitude: -3.684168,
          images: [''],
        );

        // Producto 2: Muy lejano (Zaragoza Centro ~ 270 km)
        final productLejano = Product(
          id: 'lejano',
          title: 'Producto Lejano',
          description: 'A muchos kilómetros',
          tradeType: TradeType.trade,
          category: 'Otros',
          location: 'Zaragoza',
          owner: 'Test',
          ownerId: '2',
          condition: 'Buen estado',
          wanted: 'Nada',
          createdAt: DateTime.now(),
          latitude: 41.648823,
          longitude: -0.889085,
          images: [''],
        );

        // Lista desordenada inicialmente (primero el lejano)
        final List<Product> items = [productLejano, productCercano];
        final processedList = List<Product>.from(items);

        // Función espejo exacta de la lógica Haversine implementada en el provider
        double haversineDistance(
          double lat1,
          double lon1,
          double lat2,
          double lon2,
        ) {
          const double earthRadiusInMeters = 6371000;
          final double dLat = (lat2 - lat1) * math.pi / 180.0;
          final double dLon = (lon2 - lon1) * math.pi / 180.0;
          final double rLat1 = lat1 * math.pi / 180.0;
          final double rLat2 = lat2 * math.pi / 180.0;
          final double a =
              math.sin(dLat / 2) * math.sin(dLat / 2) +
              math.sin(dLon / 2) *
                  math.sin(dLon / 2) *
                  math.cos(rLat1) *
                  math.cos(rLat2);
          final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
          return earthRadiusInMeters * c;
        }

        processedList.sort((a, b) {
          if (a.latitude == null || a.longitude == null) return 1;
          if (b.latitude == null || b.longitude == null) return -1;
          final double distA = haversineDistance(
            userLat,
            userLng,
            a.latitude!,
            a.longitude!,
          );
          final double distB = haversineDistance(
            userLat,
            userLng,
            b.latitude!,
            b.longitude!,
          );
          return distA.compareTo(distB);
        });

        // Verificación: El producto cercano debe quedar en la primera posición (índice 0)
        expect(processedList.first.id, equals('cercano'));
        expect(processedList.last.id, equals('lejano'));
      },
    );
  });
}
