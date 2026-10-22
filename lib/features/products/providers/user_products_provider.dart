import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/features/products/providers/product_repository_provider.dart';

final userProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final allProducts = await repository.getProducts();
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;
  if (currentUserId == null) return [];
  return allProducts.where((p) => p.userId == currentUserId).toList();
});
