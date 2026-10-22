import 'package:cross_file/cross_file.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/models/product.dart';

class ProductRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Product>> getProducts({
    String? query,
    String? category,
    double? userLatitude,
    double? userLongitude,
    double? radiusInKm,
    int? page,
    int? limit,
  }) async {
    var queryBuilder = _supabase.from('products').select();
    
    if (query != null && query.isNotEmpty) {
      queryBuilder = queryBuilder.ilike('title', '%$query%');
    }
    if (category != null && category.isNotEmpty && category != 'Todos') {
      queryBuilder = queryBuilder.eq('category', category);
    }
    
    final response = await queryBuilder;
    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  Future<Product?> getProductById(String id) async {
    final response = await _supabase.from('products').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return Product.fromJson(response);
  }

  Future<List<Product>> searchProductsAdvanced({
    required String query,
    required double latitude,
    required double longitude,
    required double maxRadiusMeters,
  }) async {
    return getProducts(
      query: query,
      userLatitude: latitude,
      userLongitude: longitude,
      radiusInKm: maxRadiusMeters / 1000,
    );
  }

  Future<void> createProduct(Product product) async {
    await _supabase.from('products').insert(product.toJson());
  }

  Future<void> updateProduct(Product product) async {
    await _supabase.from('products').update(product.toJson()).eq('id', product.id);
  }

  Future<void> deleteProduct(String id) async {
    await _supabase.from('products').delete().eq('id', id);
  }

  Future<void> incrementViews(String id) async {
    try {
      final product = await getProductById(id);
      if (product != null) {
        await _supabase.from('products').update({'views': product.viewsCount + 1}).eq('id', id);
      }
    } catch (_) {}
  }

  Future<String> uploadProductImage(XFile file) async {
    final fileName = 'prod_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final bytes = await file.readAsBytes();
    
    // Subida limpia mediante uploadBinary
    await _supabase.storage.from('product-images').uploadBinary(fileName, bytes);
        
    return _supabase.storage.from('product-images').getPublicUrl(fileName);
  }

  Future<void> deleteProductImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments.last;
        await _supabase.storage.from('product-images').remove([fileName]);
      }
    } catch (_) {}
  }
}
