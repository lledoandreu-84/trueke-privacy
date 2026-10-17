import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product_model.dart';
import 'product_repository.dart';

// Proveedor para inyectar la instancia global de Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Proveedor para inicializar nuestro repositorio de datos
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProductRepository(client);
});

// Notifier que gestiona el estado de la lista de productos filtrada
final productSearchProvider =
    AsyncNotifierProvider<ProductSearchNotifier, List<ProductModel>>(() {
      return ProductSearchNotifier();
    });

class ProductSearchNotifier extends AsyncNotifier<List<ProductModel>> {
  List<ProductModel> _allProducts = [];

  @override
  Future<List<ProductModel>> build() async {
    // Carga inicial de datos al arrancar el proveedor
    final repository = ref.read(productRepositoryProvider);
    _allProducts = await repository.fetchProducts();
    return _allProducts;
  }

  // Ejecuta el filtrado reactivo basado en el término de búsqueda
  void filterProducts(String query) {
    if (query.isEmpty) {
      state = AsyncData(_allProducts);
      return;
    }

    final filtered = _allProducts.where((product) {
      final titleMatch = product.title.toLowerCase().contains(
        query.toLowerCase(),
      );
      final descriptionMatch = product.description.toLowerCase().contains(
        query.toLowerCase(),
      );
      return titleMatch || descriptionMatch;
    }).toList();

    state = AsyncData(filtered);
  }
}
