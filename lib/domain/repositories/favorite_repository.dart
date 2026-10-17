import '../../features/products/domain/product_model.dart';

abstract class FavoriteRepository {
  Stream<List<String>> watchFavoriteIds(String userId);
  Future<void> toggleFavorite(String userId, String productId, bool isFavorite);
  Future<List<Product>> getFavoriteProducts(String userId);
}
