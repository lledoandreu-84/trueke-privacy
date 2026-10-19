import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/products/repositories/supabase_product_repository.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

void main() {
  group('SupabaseProductRepository con fallback de mocks', () {
    late FakeSupabaseClient fakeClient;
    late SupabaseProductRepository repository;

    final testRemoteProductJson = {
      'id': 'prod_real_999',
      'title': 'Producto de Red Activa',
      'description': 'Descripción del producto remoto en Supabase',
      'price': 150.0,
      'trade_type': 'trade',
      'category': 'Electrónica',
      'location': 'Sevilla, Centro',
      'owner': 'TestUser',
      'condition': 'Nuevo',
      'wanted': 'Intercambio',
      'created_at': DateTime.now().toIso8601String(),
      'latitude': 37.389092,
      'longitude': -5.984459,
      'images': ['https://example.com/product.jpg'],
    };

    setUp(() {
      fakeClient = FakeSupabaseClient();
    });

    test(
      'devuelve los productos recibidos sin añadir anuncios ficticios',
      () async {
        repository = SupabaseProductRepository(
          fakeClient,
          mockGetProductsInterceptor: () async => [testRemoteProductJson],
        );

        final products = await repository.getProducts();

        expect(products.map((p) => p.id), ['prod_real_999']);
      },
    );

    test(
      'devuelve los productos mock de respaldo si falla la consulta',
      () async {
        repository = SupabaseProductRepository(
          fakeClient,
          mockGetProductsInterceptor: () async =>
              throw Exception('Network connection failure'),
        );

        final products = await repository.getProducts();

        expect(products, isNotEmpty);
        expect(products.first.id, startsWith('m'));
      },
    );
  });
}
