import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/core/supabase/supabase_client.dart';
import '../repositories/product_repository.dart';
import '../repositories/supabase_product_repository.dart';

final productRepositoryProvider = Provider.autoDispose<ProductRepository>((
  ref,
) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProductRepository(client);
});
