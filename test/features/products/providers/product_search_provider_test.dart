import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/features/products/repositories/product_repository.dart';
import 'package:trueke/features/products/providers/product_repository_provider.dart';
import 'package:trueke/features/products/providers/product_search_provider.dart';

class FakeProductRepository extends Fake implements ProductRepository {
  bool searchCalled = false;
  double? capturedRadius;

  @override
  Future<List<Product>> searchProductsAdvanced({
    required String query,
    required double longitude,
    required double latitude,
    required double maxRadiusMeters,
  }) async {
    searchCalled = true;
    capturedRadius = maxRadiusMeters;
    return [
      Product(
        id: 'prod_test_01',
        title: 'Bicicleta de montaña',
        description: 'En perfecto estado',
        price: 150.0,
        category: 'Deporte',
        condition: 'como nuevo',
        tradeType: TradeType.trade,
        images: ['https://supabase.co'],
        location: 'Madrid, España',
        owner: 'David',
        ownerId: 'usr_owner_1',
        wanted: 'Cualquier cosa de tecnología',
        createdAt: DateTime.now(),
        latitude: 40.416775,
        longitude: -3.703790,
      ),
    ];
  }
}

void main() {
  group('ProductSearchNotifier - Pruebas de Consistencia Espacial', () {
    late ProviderContainer container;
    late FakeProductRepository fakeRepository;

    setUp(() {
      fakeRepository = FakeProductRepository();
      container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'Debe convertir con exactitud los kilometros a metros e inyectar AsyncData tras busqueda exitosa',
      () async {
        final notifier = container.read(productSearchNotifierProvider.notifier);

        notifier.updateRadius(20.0);
        await notifier.search();

        final state = container.read(productSearchNotifierProvider);

        expect(fakeRepository.searchCalled, isTrue);
        expect(fakeRepository.capturedRadius, equals(20000.0));
        expect(state.products, isA<AsyncData<List<Product>>>());
        expect(state.products.value!.length, equals(1));
        expect(
          state.products.value!.first.title,
          equals('Bicicleta de montaña'),
        );
      },
    );

    test(
      'Debe descartar productos si se encuentran fuera del rango de precios configurado',
      () async {
        final notifier = container.read(productSearchNotifierProvider.notifier);

        // 1. Ejecutar búsqueda base inicial para asentar el AsyncData con la bicicleta de 150€
        await notifier.search();

        // 2. Restringir el rango de precio a un margen superior (200€ - 500€) lo cual gatilla el search() interno
        notifier.updatePriceRange(200.0, 500.0);

        // Permitir un tick del lazo de eventos de Dart para que complete el search() asíncrono interno
        await Future.delayed(Duration.zero);

        final state = container.read(productSearchNotifierProvider);

        // El sumatorio elástico del bypass offline debe vaciar la lista (150€ queda fuera de 200€-500€)
        expect(state.products.value, isEmpty);
      },
    );
  });
}
