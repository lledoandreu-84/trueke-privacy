import 'dart:io';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/mocks/mock_product_service.dart';
import '../../../models/product.dart';
import 'product_repository.dart';

class SupabaseProductRepository implements ProductRepository {
  SupabaseProductRepository(this._client, {this.mockGetProductsInterceptor})
    : _storageService = StorageService(client: _client);

  final Future<List<dynamic>> Function()? mockGetProductsInterceptor;
  final SupabaseClient _client;
  final StorageService _storageService;

  static const _table = 'products';

  List<Product> _getMockFallback({String? query, String? category}) {
    var products = MockProductService.getFullMockProducts();
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      products = products.where((p) =>
        p.title.toLowerCase().contains(q) ||
        p.description.toLowerCase().contains(q)
      ).toList();
    }
    if (category != null && category.trim().isNotEmpty) {
      final cat = category.trim().toLowerCase();
      products = products.where((p) => p.category.toLowerCase() == cat).toList();
    }
    return products;
  }

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
    if (mockGetProductsInterceptor != null) {
      try {
        final response = await mockGetProductsInterceptor!();
        final fetchedProducts = response
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
        return fetchedProducts;
      } catch (e) {
        return _getMockFallback(query: query, category: category);
      }
    }
    try {
      List<dynamic> response;
      final hasPagination = page != null && limit != null;
      final int from = hasPagination ? (page * limit) : 0;
      final int to = hasPagination ? (from + limit - 1) : 0;

      if (userLatitude != null && userLongitude != null && radiusInKm != null) {
        final Map<String, dynamic> rpcParams = {
          'user_latitude': userLatitude,
          'user_longitude': userLongitude,
          'max_distance_km': radiusInKm,
          'search_query': query ?? '',
          'filter_category': category ?? '',
        };
        if (hasPagination) {
          rpcParams['page_offset'] = from;
          rpcParams['page_limit'] = limit;
        }
        response =
            await _client.rpc('search_products_by_distance', params: rpcParams)
                as List<dynamic>;
      } else {
        var builder = _client.from(_table).select();
        if (query != null && query.isNotEmpty) {
          builder = builder.or(
            'title.ilike.%$query%,description.ilike.%$query%',
          );
        }
        if (category != null && category.isNotEmpty) {
          builder = builder.eq('category', category);
        }

        var queryOrder = builder.order('created_at', ascending: false);
        if (hasPagination) {
          response = await queryOrder.range(from, to) as List<dynamic>;
        } else {
          response = await queryOrder as List<dynamic>;
        }
      }

      final fetchedProducts = response
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();

      if (fetchedProducts.isEmpty) {
        return _getMockFallback(query: query, category: category);
      }

      return fetchedProducts;
    } catch (e) {
      developer.log(
        '⚠️ [FALLO REPOSITORIO] | getProducts fallback mock activado | Error: $e',
        name: 'trueke.repository',
      );
      return _getMockFallback(query: query, category: category);
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response != null) {
        return Product.fromJson(response);
      }
    } catch (_) {}
    
    try {
      return MockProductService.getFullMockProducts().firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createProduct(Product product) async {
    await _client.from(_table).insert(product.toJson());
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _client.from(_table).update(product.toJson()).eq('id', product.id);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  @override
  Future<String> uploadProductImage(XFile file) async {
    return _storageService.uploadProductImage(File(file.path));
  }

  @override
  Future<void> deleteProductImage(String publicUrl) async {
    await _storageService.deleteProductImage(publicUrl);
  }

  @override
  Future<void> incrementViews(String productId) async {
    try {
      // Intentamos actualizar directamente incrementando views_count
      final existing = await _client
          .from(_table)
          .select('views_count')
          .eq('id', productId)
          .maybeSingle();
      
      if (existing != null) {
        final currentViews = (existing['views_count'] as int?) ?? 0;
        await _client
            .from(_table)
            .update({'views_count': currentViews + 1})
            .eq('id', productId);
      }
    } catch (e) {
      developer.log('⚠️ No se pudo incrementar vistas remotas: $e', name: 'trueke.repository');
    }
  }

  @override
  Future<List<Product>> searchProductsAdvanced({
    required String query,
    required double longitude,
    required double latitude,
    required double maxRadiusMeters,
  }) async {
    try {
      final radiusKm = maxRadiusMeters / 1000.0;
      final response = await _client.rpc(
        'search_products_by_distance',
        params: {
          'user_latitude': latitude,
          'user_longitude': longitude,
          'max_distance_km': radiusKm,
          'search_query': query.trim().isEmpty ? null : query.trim(),
        },
      );
      if (response != null) {
        final list = (response as List<dynamic>)
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      developer.log(
        '⚠️ [FALLO REPOSITORIO] | searchProductsAdvanced fallback mock | Error: $e',
        name: 'trueke.repository',
      );
    }
    return _getMockFallback(query: query);
  }
}
