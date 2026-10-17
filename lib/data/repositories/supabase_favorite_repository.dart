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
        .select('products(*)')
        .eq('user_id', userId);

    return response.map((item) {
      final productMap = item['products'] as Map<String, dynamic>;
      return Product.fromJson(productMap);
    }).toList();
  }
}
