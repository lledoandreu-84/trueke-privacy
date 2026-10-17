import 'package:trueke/features/products/providers/product_filters_provider.dart';

abstract class SearchRepository {
  /// Realiza una búsqueda avanzada mapeando filtros sobre el backend.
  /// Devuelve una lista de mapas (JSON) listos para ser transformados en modelos de producto.
  Future<List<Map<String, dynamic>>> searchProducts(ProductFilters filters);
}
