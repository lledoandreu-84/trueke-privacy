import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/product.dart';
import 'products_provider.dart';

final matchProvider = Provider<AsyncValue<List<Map<String, Product>>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;

  return productsAsync.whenData((products) {
    if (currentUserId == null) return [];

    final myProducts = products.where((p) => p.ownerId == currentUserId).toList();
    final otherProducts = products.where((p) => p.ownerId != currentUserId).toList();

    List<Map<String, Product>> matches = [];

    for (var myProduct in myProducts) {
      for (var otherProduct in otherProducts) {
        // Normalizamos a minúsculas para evitar problemas con mayúsculas
        final myWanted = myProduct.wanted.trim().toLowerCase();
        final otherCategory = otherProduct.category.trim().toLowerCase();
        
        final otherWanted = otherProduct.wanted.trim().toLowerCase();
        final myCategory = myProduct.category.trim().toLowerCase();

        if (myWanted == otherCategory && otherWanted == myCategory) {
          matches.add({
            'myProduct': myProduct,
            'matchedProduct': otherProduct,
          });
        }
      }
    }

    return matches;
  });
});
