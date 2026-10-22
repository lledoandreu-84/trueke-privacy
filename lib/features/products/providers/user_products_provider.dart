import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/models/product.dart';

final userProductsProvider = FutureProvider<List<Product>>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  if (user == null) return [];

  try {
    // Consultamos directamente filtrando por owner_id y por el email/propietario como respaldo
    final response = await supabase
        .from('products')
        .select()
        .or('owner_id.eq.${user.id},owner.eq.${user.email ?? ''}');

    return (response as List).map((json) => Product.fromJson(json)).toList();
  } catch (_) {
    // Fallback de seguridad en caso de error en la query compuesta
    final response = await supabase
        .from('products')
        .select()
        .eq('owner_id', user.id);

    return (response as List).map((json) => Product.fromJson(json)).toList();
  }
});
