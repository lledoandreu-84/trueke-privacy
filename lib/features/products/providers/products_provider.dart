import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trueke/core/supabase/supabase_client.dart';
import '../../../models/product.dart';
import 'product_repository_provider.dart';
import 'product_filters_provider.dart';

final productsProvider =
    AsyncNotifierProvider.autoDispose<ProductsNotifier, List<Product>>(() {
      return ProductsNotifier();
    });

final myProductsProvider = Provider.autoDispose<AsyncValue<List<Product>>>((
  ref,
) {
  final productsAsync = ref.watch(productsProvider);
  final myId = ref.watch(supabaseClientProvider).auth.currentUser?.id;
  return productsAsync.whenData((list) {
    return list.where((p) => p.ownerId == myId).toList();
  });
});

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final filters = ref.watch(productFiltersProvider);

    final rawProducts = await ref
        .watch(productRepositoryProvider)
        .getProducts(
          userLatitude: filters.userLatitude,
          userLongitude: filters.userLongitude,
          radiusInKm: filters.radiusInKm,
        );

    final normalizedQuery = filters.query.toLowerCase();
    final targetCategory = filters.category;

    return rawProducts.where((product) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          [
            product.title,
            product.description,
            product.category,
          ].any((value) => value.toLowerCase().contains(normalizedQuery));

      String normalize(String text) {
        return text
            .toLowerCase()
            .replaceAll(RegExp(r'[áàäâ]'), 'a')
            .replaceAll(RegExp(r'[éèëê]'), 'e')
            .replaceAll(RegExp(r'[íìïî]'), 'i')
            .replaceAll(RegExp(r'[óòöô]'), 'o')
            .replaceAll(RegExp(r'[úùüû]'), 'u')
            .replaceAll(RegExp(r'\s+'), '');
      }

      final matchesCategory =
          targetCategory == null ||
          (normalize(product.category) == normalize(targetCategory));

      return matchesQuery && matchesCategory;
    }).toList();
  }

  Future<void> addProduct(Product product) async {
    try {
      await ref.read(productRepositoryProvider).createProduct(product);
      ref.invalidateSelf();
        // Refrescar vistas globales
        ref.invalidate(productsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await ref.read(productRepositoryProvider).updateProduct(product);
      ref.invalidateSelf();
        // Refrescar vistas globales
        ref.invalidate(productsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<String> uploadProductImage(XFile image) async {
    try {
      return await ref
          .read(productRepositoryProvider)
          .uploadProductImage(image);
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  Future<void> deleteProduct(Product product) async {
    try {
      final repo = ref.read(productRepositoryProvider);
      if (product.imageUrl.isNotEmpty) {
        try {
          await repo.deleteProductImage(product.imageUrl);
        } catch (_) {}
      }
      await repo.deleteProduct(product.id);
      
      if (!ref.mounted) return;

      // Actualización optimista local del estado
      if (state.hasValue) {
        final currentList = state.value ?? [];
        state = AsyncValue.data(currentList.where((p) => p.id != product.id).toList());
      }

      if (ref.mounted) {
        ref.invalidateSelf();
        // Refrescar vistas globales
        ref.invalidate(productsProvider);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteProductImage(String url) async {
    await ref.read(productRepositoryProvider).deleteProductImage(url);
  }
}
