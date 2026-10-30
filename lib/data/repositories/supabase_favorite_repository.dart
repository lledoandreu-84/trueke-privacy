import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../../features/products/domain/product_model.dart';

class SupabaseFavoriteRepository implements FavoriteRepository {
  final SupabaseClient _client;

  SupabaseFavoriteRepository(this._client);

  @override
  Stream<List<String>> watchFavoriteIds(String userId) {
    return _client
        .from('favorites')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((maps) => maps.map((map) => map['product_id'] as String).toList());
  }

  @override
  Future<void> toggleFavorite(
    String userId,
    String productId,
    bool isFavorite,
  ) async {
    if (isFavorite) {
      await _client.from('favorites').insert({
        'user_id': userId,
        'product_id': productId,
      });

      try {
        final productResponse = await _client
            .from('products')
            .select('user_id, title')
            .eq('id', productId)
            .maybeSingle();

        if (productResponse != null) {
          final ownerId = productResponse['user_id'] as String?;
          final productTitle = productResponse['title'] as String? ?? 'tu producto';

          if (ownerId != null && ownerId != userId) {
            await _client.from('notifications').insert({
              'user_id': ownerId,
              'title': '¡Nuevo interesado!',
              'message': 'A alguien le interesa tu producto "$productTitle".',
              'type': 'favorite',
            });
          }
        }
      } catch (_) {}
    } else {
      await _client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
    }
  }

  @override
  Future<List<Product>> getFavoriteProducts(String userId) async {
    final PostgrestList response = await _client
        .from('favorites')
        .select('product_id, products(*)')
        .eq('user_id', userId);

    final List<Product> favoriteProducts = [];
    for (final item in response) {
      final productMap = item['products'];
      if (productMap is Map<String, dynamic>) {
        final productOwnerId = productMap['user_id'] as String? ?? 
                               productMap['owner_id'] as String?;

        // Descartar de forma estricta los productos propios del usuario actual
        if (productOwnerId != userId) {
          favoriteProducts.add(Product.fromJson(productMap));
        }
      }
    }
    return favoriteProducts;
  }
}
