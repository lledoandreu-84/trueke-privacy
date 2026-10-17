import 'dart:io';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/storage_service.dart';
import '../../../models/product.dart';
import 'product_repository.dart';

class SupabaseProductRepository implements ProductRepository {
  SupabaseProductRepository(this._client, {this.mockGetProductsInterceptor})
    : _storageService = StorageService(client: _client);

  final Future<List<dynamic>> Function()? mockGetProductsInterceptor;
  final SupabaseClient _client;
  final StorageService _storageService;

  static const _table = 'products';

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
        developer.log(
          'Error obteniendo productos mediante el interceptor de pruebas: $e',
          name: 'trueke.repository',
          error: e,
        );
        return [];
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

      final cleanRealProducts = fetchedProducts.where((p) {
        if (p.images.isNotEmpty &&
            p.images.first.contains('unsplash.com') &&
            !p.images.first.contains('://unsplash.com')) {
          return false;
        }
        return true;
      }).toList();

      return cleanRealProducts;
    } catch (e) {
      developer.log(
        '⚠️ [FALLO REPOSITORIO] | getProducts geo fallback activado | Error: $e',
        name: 'trueke.repository',
        error: e,
      );
      return [];
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();
    return response == null ? null : Product.fromJson(response);
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
        return (response as List<dynamic>)
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      developer.log(
        '⚠️ [FALLO REPOSITORIO] | searchProductsAdvanced fallado | Error: $e',
        name: 'trueke.repository',
        error: e,
      );
      return [];
    }
  }
}
