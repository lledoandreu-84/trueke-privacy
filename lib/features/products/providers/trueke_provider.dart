import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/product.dart';
import 'products_provider.dart';

final truekeProvider = Provider<AsyncValue<List<Map<String, Product>>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;

  return productsAsync.whenData((products) {
    if (currentUserId == null) return [];

    final myProducts = products.where((p) => p.ownerId == currentUserId).toList();
    final otherProducts = products.where((p) => p.ownerId != currentUserId).toList();

    List<Map<String, Product>> truekes = [];

    for (var myProduct in myProducts) {
      for (var otherProduct in otherProducts) {
        final myWanted = myProduct.wanted.trim().toLowerCase();
        final otherTitle = otherProduct.title.trim().toLowerCase();
        
        final otherWanted = otherProduct.wanted.trim().toLowerCase();
        final myTitle = myProduct.title.trim().toLowerCase();

        // Comprobamos si lo que busco está en el título del otro, y viceversa
        if (myWanted.isNotEmpty && otherWanted.isNotEmpty &&
            (otherTitle.contains(myWanted) || myWanted.contains(otherTitle)) &&
            (myTitle.contains(otherWanted) || otherWanted.contains(myTitle))) {
          truekes.add({
            'myProduct': myProduct,
            'truekeProduct': otherProduct,
          });
        }
      }
    }

    return truekes;
  });
});
