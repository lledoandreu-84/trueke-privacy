import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/products/domain/product_model.dart';
import '../../main.dart';

class FavoritesNotifier extends AsyncNotifier<List<Product>> {
  String get _favoritesKey {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'guest';
    return 'user_favorite_products_${userId}_v4';
  }

  @override
  Future<List<Product>> build() async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final preferences = ref.watch(sharedPreferencesProvider);
    final jsonList = preferences.getStringList(_favoritesKey) ?? [];

    final List<Product> list = [];
    for (final item in jsonList) {
      try {
        final Map<String, dynamic> decoded =
            jsonDecode(item) as Map<String, dynamic>;

        if (!decoded.containsKey('image_urls') &&
            decoded.containsKey('images')) {
          decoded['image_urls'] = decoded['images'];
        }
        if (!decoded.containsKey('trade_type') &&
            decoded.containsKey('tradeType')) {
          decoded['trade_type'] = decoded['tradeType'];
        }

        final product = Product.fromJson(decoded);

        // Identificar el ID del propietario en el JSON guardado
        final productOwnerId = decoded['user_id'] as String? ??
                               decoded['owner_id'] as String? ??
                               decoded['userId'] as String? ??
                               decoded['ownerId'] as String?;

        // Excluir estrictamente si el producto pertenece al usuario actual
        if (currentUserId != null && productOwnerId != null && productOwnerId.trim() == currentUserId.trim()) {
          continue;
        }

        list.add(product);
      } catch (_) {}
    }

    // Si se filtraron productos propios obsoletos, actualizar la caché local
    if (list.length != jsonList.length) {
      final cleanedJsonList = list.map((p) => jsonEncode(p.toJson())).toList();
      await preferences.setStringList(_favoritesKey, cleanedJsonList);
    }

    return list;
  }

  bool isFavorite(String productId) {
    final cleanId = productId.trim().toLowerCase();
    return state.value?.any(
          (item) => item.id.toString().trim().toLowerCase() == cleanId,
        ) ??
        false;
  }

  Future<void> toggleFavorite(Product product) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final productMap = product.toJson();
    final productOwnerId = productMap['user_id'] as String? ??
                           productMap['owner_id'] as String? ??
                           productMap['userId'] as String? ??
                           productMap['ownerId'] as String?;

    // Prevenir que un usuario añada su propio producto a favoritos
    if (currentUserId != null && productOwnerId != null && productOwnerId.trim() == currentUserId.trim()) {
      return;
    }

    final currentFavorites = state.value ?? [];
    final currentId = product.id.toString().trim().toLowerCase();

    final isCurrentlyFavorite = currentFavorites.any(
      (item) => item.id.toString().trim().toLowerCase() == currentId,
    );

    List<Product> updatedFavorites;
    if (isCurrentlyFavorite) {
      updatedFavorites = currentFavorites
          .where((item) => item.id.toString().trim().toLowerCase() != currentId)
          .toList();
    } else {
      updatedFavorites = [...currentFavorites, product];
    }

    final preferences = ref.read(sharedPreferencesProvider);
    final jsonList = updatedFavorites
        .map((p) => jsonEncode(p.toJson()))
        .toList();

    await preferences.setStringList(_favoritesKey, jsonList);
    state = AsyncData(updatedFavorites);
  }

  void updateAvailableProducts(List<Product> freshProducts) {
    if (state.isLoading || state.hasError) return;
    final currentFavorites = state.value ?? [];
    if (currentFavorites.isEmpty || freshProducts.isEmpty) return;

    bool hasChanges = false;
    final updatedFavorites = currentFavorites.map((favItem) {
      final freshMatch = freshProducts.firstWhere(
        (p) =>
            p.id.toString().trim().toLowerCase() ==
            favItem.id.toString().trim().toLowerCase(),
        orElse: () => favItem,
      );

      if (freshMatch != favItem) {
        hasChanges = true;
        return freshMatch;
      }
      return favItem;
    }).toList();

    if (hasChanges) {
      final preferences = ref.read(sharedPreferencesProvider);
      final jsonList = updatedFavorites
          .map((p) => jsonEncode(p.toJson()))
          .toList();
      preferences.setStringList(_favoritesKey, jsonList);
      state = AsyncData(updatedFavorites);
    }
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<Product>>(() {
      return FavoritesNotifier();
    });
