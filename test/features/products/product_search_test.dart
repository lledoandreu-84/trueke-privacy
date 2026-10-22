import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/products/providers/product_search_provider.dart';
import 'package:trueke/features/products/providers/product_repository_provider.dart';
import 'package:trueke/models/product.dart';

class MockProductRepository implements ProductRepository {
  final List<Product> mockResults;

  MockProductRepository({required this.mockResults});

  @override
  Future<List<Product>> searchProductsAdvanced({
    required String query,
    required double longitude,
    required double latitude,
    required double maxRadiusMeters,
  }) async {
    return mockResults;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ProductSearchNotifier Tests', () {
    test('El estado inicial debe configurarse correctamente sobre Madrid', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(productSearchNotifierProvider);

      expect(state.query, equals(''));
      expect(state.maxRadiusKm, equals(9999.0));
      expect(state.latitude, equals(40.416775));
      expect(state.longitude, equals(-3.703790));
      expect(state.products.value, isEmpty);
    });

    test(
      'updateQuery y updateRadius deben mutar el estado de forma inmutable',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(productSearchNotifierProvider.notifier);

        notifier.updateQuery('bicicleta');
        notifier.updateRadius(25.0);

        final state = container.read(productSearchNotifierProvider);
        expect(state.query, equals('bicicleta'));
        expect(state.maxRadiusKm, equals(25.0));
      },
    );

    test(
      'search debe emitir carga y posteriormente depositar los productos del repositorio',
      () async {
        final mockRepo = MockProductRepository(mockResults: const []);

        final container = ProviderContainer(
          overrides: [
            productRepositoryProvider.overrideWith((ref) => mockRepo),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(productSearchNotifierProvider.notifier);
        notifier.updateQuery('bicicleta');

        final future = notifier.search();

        expect(
          container.read(productSearchNotifierProvider).products,
          const AsyncValue<List<Product>>.loading(),
        );

        await future;

        final finalState = container.read(productSearchNotifierProvider);
        expect(finalState.products.hasValue, isTrue);
        expect(finalState.products.value, isEmpty);
      },
    );
  });
}
