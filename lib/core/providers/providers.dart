import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/core/supabase/supabase_client.dart';
import '../../features/products/repositories/product_repository.dart';
import '../../features/products/repositories/supabase_product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProductRepository(client);
});
