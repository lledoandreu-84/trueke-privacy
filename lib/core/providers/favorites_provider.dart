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

        list.add(Product.fromJson(decoded));
      } catch (_) {}
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
