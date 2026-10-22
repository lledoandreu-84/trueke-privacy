import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/features/products/providers/product_repository_provider.dart';

final userProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final allProducts = await repository.getProducts();
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return [];

  final currentUserId = user.id;
  final currentEmail = user.email;
  final currentName = user.userMetadata?['full_name'];

  return allProducts.where((p) {
    return p.ownerId == currentUserId ||
           (currentEmail != null && p.ownerId == currentEmail) ||
           (currentName != null && p.owner == currentName) ||
           (currentEmail != null && p.owner == currentEmail);
  }).toList();
});
