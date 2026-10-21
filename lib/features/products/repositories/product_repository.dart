import 'package:image_picker/image_picker.dart';
import '../../../models/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({
    String? query,
    String? category,
    double? userLatitude,
    double? userLongitude,
    double? radiusInKm,
    int? page,
    int? limit,
  });

  Future<Product?> getProductById(String id);

  Future<void> createProduct(Product product);

  Future<void> updateProduct(Product product);

  Future<void> deleteProduct(String id);

  Future<String> uploadProductImage(XFile file);

  Future<void> deleteProductImage(String publicUrl);

  Future<void> incrementViews(String productId);

  Future<List<Product>> searchProductsAdvanced({
    required String query,
    required double longitude,
    required double latitude,
    required double maxRadiusMeters,
  });
}
