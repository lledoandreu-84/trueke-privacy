import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueke/features/products/providers/paginated_products_provider.dart';
import 'package:trueke/features/products/providers/product_repository_provider.dart';
import 'package:trueke/models/product.dart';

class FakeCacheProductRepository extends Fake implements ProductRepository {
  FakeCacheProductRepository({required this.products, this.shouldFail = false});

  final List<Product> products;
  final bool shouldFail;

  @override
  Future<List<Product>> getProducts({
    String? query,
    String? category,
    double? userLatitude,
    double? userLongitude,
    double? radiusInKm,
    int? page,
    int? limit,
  }) async {
    if (shouldFail) {
      throw Exception('Simulated network failure');
    }
    return products;
  }
}

Product makeProduct(String id) {
  return Product(
    id: id,
    title: 'Producto $id',
    description: 'Producto de prueba',
    price: 10,
    images: const ['https://example.com/product.jpg'],
    category: 'Hogar',
    owner: 'Usuario de prueba',
    ownerId: 'user_real_1',
    condition: 'Nuevo',
    tradeType: TradeType.trade,
    wanted: 'Intercambio',
    location: 'Sevilla',
    createdAt: DateTime.utc(2026, 1, 1),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const cacheKey = 'cached_feed_products_v4';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Caché del catálogo sin productos ficticios', () {
    test(
      'filtra IDs mock_ de la caché y conserva productos reales sin conexión',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          cacheKey,
          jsonEncode([
            makeProduct('prod_real_cached_1').toJson(),
            makeProduct('mock_electrónica').toJson(),
            makeProduct('mock_moda').toJson(),
          ]),
        );

        final repository = FakeCacheProductRepository(
          products: const [],
          shouldFail: true,
        );

        final container = ProviderContainer(
          overrides: [productRepositoryProvider.overrideWithValue(repository)],
        );

        try {
          final result = await container.read(paginatedProductsProvider.future);

          expect(result.products.map((product) => product.id).toList(), [
            'prod_real_cached_1',
          ]);
          expect(
            result.products.any((product) => product.id.startsWith('mock_')),
            isFalse,
          );

          // La caché original no se borra ni se vacía por completo.
          expect(prefs.getString(cacheKey), isNotNull);
        } finally {
          container.dispose();
        }
      },
    );

    test(
      'no guarda productos mock_ cuando recibe productos del repositorio',
      () async {
        final repository = FakeCacheProductRepository(
          products: [
            makeProduct('prod_real_remote_1'),
            makeProduct('mock_hogar'),
          ],
        );

        final container = ProviderContainer(
          overrides: [productRepositoryProvider.overrideWithValue(repository)],
        );

        try {
          final result = await container.read(paginatedProductsProvider.future);

          expect(result.products.map((product) => product.id).toList(), [
            'prod_real_remote_1',
            'mock_hogar',
          ]);

          // La lista de la sesión no se altera; el filtro se aplica al persistir.
          await Future<void>.delayed(const Duration(milliseconds: 50));

          final prefs = await SharedPreferences.getInstance();
          final raw = prefs.getString(cacheKey);
          expect(raw, isNotNull);

          final cached = (jsonDecode(raw!) as List<dynamic>)
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();

          expect(cached.map((product) => product.id).toList(), [
            'prod_real_remote_1',
          ]);
        } finally {
          container.dispose();
        }
      },
    );
  });
}
