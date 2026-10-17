import 'package:supabase_flutter/supabase_flutter.dart';
import 'product_model.dart';

class ProductRepository {
  final SupabaseClient _supabaseClient;

  ProductRepository(this._supabaseClient);

  // Descarga todos los productos de la tabla 'products' ordenados por fecha de creación
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await _supabaseClient
          .from('products')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al cargar productos de Supabase: $e');
    }
  }
}
