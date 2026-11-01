require 'fileutils'

provider_content = <<~DART
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/product.dart';
import 'products_provider.dart';

final hiddenTruekesProvider = Provider<ValueNotifier<List<String>>>((ref) {
  return ValueNotifier<List<String>>([]);
});

final truekeMatchesProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final hiddenNotifier = ref.watch(hiddenTruekesProvider);
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;

  return productsAsync.whenData((products) {
    if (currentUserId == null) return [];
    
    final myProducts = products.where((p) => p.ownerId == currentUserId).toList();
    final otherProducts = products.where((p) => p.ownerId != currentUserId).toList();
    
    List<Map<String, dynamic>> truekes = [];

    for (var myProduct in myProducts) {
      for (var otherProduct in otherProducts) {
        final myWanted = myProduct.wanted.trim().toLowerCase().replaceAll('s', '');
        final otherTitle = otherProduct.title.trim().toLowerCase().replaceAll('s', '');
        
        final otherWanted = otherProduct.wanted.trim().toLowerCase().replaceAll('s', '');
        final myTitle = myProduct.title.trim().toLowerCase().replaceAll('s', '');

        if (myWanted.isNotEmpty && otherWanted.isNotEmpty &&
            (otherTitle.contains(myWanted) || myWanted.contains(otherTitle)) &&
            (myTitle.contains(otherWanted) || otherWanted.contains(myTitle))) {
          
          final matchId = '\${myProduct.id}-\${otherProduct.id}';
          if (!hiddenNotifier.value.contains(matchId)) {
            truekes.add({
              'myProduct': myProduct,
              'truekeProduct': otherProduct,
              'matchId': matchId,
            });
          }
        }
      }
    }
    return truekes;
  });
});
DART

File.write('lib/features/products/providers/trueke_provider.dart', provider_content)
