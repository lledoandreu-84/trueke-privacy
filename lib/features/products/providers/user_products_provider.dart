import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/models/product.dart';
import 'products_provider.dart';

final userProductsProvider = Provider.autoDispose<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    return const AsyncValue.data([]);
  }

  return productsAsync.whenData((products) {
    return products.where((p) => p.ownerId == user.id).toList();
  });
});
