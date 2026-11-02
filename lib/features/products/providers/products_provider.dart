import '../../chat/data/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/product.dart';
import 'paginated_products_provider.dart';

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(() {
  return ProductsNotifier();
});

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    return _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    final response = await Supabase.instance.client
        .from('products')
        .select('*')
        .order('created_at', ascending: false);

    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  Future<void> deleteProduct(dynamic productOrId) async {
    final productId = productOrId is Product ? productOrId.id : productOrId.toString();
    try {
      await Supabase.instance.client
          .from('products')
          .delete()
          .eq('id', productId);

      if (!ref.mounted) return;

      state.whenData((products) {
        final updatedProducts = products.where((p) => p.id != productId).toList();
        state = AsyncValue.data(updatedProducts);
      });

      ref.invalidateSelf();
      ref.invalidate(paginatedProductsProvider);
    } catch (e, st) {
      if (!ref.mounted) return;
      state = AsyncValue.error(e, st);
    }
  }
}

final myProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;

  return productsAsync.whenData((products) {
    if (currentUserId == null) return [];
    return products.where((p) => p.ownerId == currentUserId).toList();
  });
});
