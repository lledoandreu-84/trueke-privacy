import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/models/product.dart';

final userProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  
  if (user == null) return [];

  try {
    final response = await supabase
        .from('products')
        .select()
        .eq('owner_id', user.id);

    return (response as List).map((json) => Product.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
});
