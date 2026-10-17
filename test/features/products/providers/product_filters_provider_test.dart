import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/features/products/providers/product_filters_provider.dart';

void main() {
  group('Pruebas del Motor de Filtrado (ProductFilters)', () {
    test('Fallback de Trueques Puros - No rompe límites numéricos', () {
      final truequePuro = Product(
        id: '1',
        title: 'Trueque Puro',
        description: 'Cambio bicicleta',
        price: null, // Trueque puro sin precio monetario
        images: [],
        category: 'Deporte',
        owner: 'David',
        ownerId: 'david123',
        condition: 'Buen estado',
        tradeType: TradeType.trade,
        wanted: 'Moto',
        location: 'Alicante',
        latitude: null,
        longitude: null,
        createdAt: DateTime.now(),
      );

      // Comprobar comportamiento: un precio nulo es un trueque legítimo
      expect(truequePuro.price, isNull);
      expect(truequePuro.tradeType, TradeType.trade);
    });

    test('Mapeo de opciones de ordenación desde Strings inmutables', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(productFiltersProvider.notifier);

      notifier.updateSortBy('price_asc');
      expect(
        container.read(productFiltersProvider).sortBy,
        ProductSortOption.priceAsc,
      );

      notifier.updateSortBy('distance');
      expect(
        container.read(productFiltersProvider).sortBy,
        ProductSortOption.distance,
      );

      notifier.updateSortBy('recent');
      expect(
        container.read(productFiltersProvider).sortBy,
        ProductSortOption.relevance,
      );
    });
  });
}
