import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'products_provider.dart';

String _normalize(String text) {
  return text.toLowerCase()
    .replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u')
    .replaceAll('v', 'b')
    .replaceAll('h', '')
    .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
    .trim();
}

final hiddenTruekesProvider = StateProvider<List<String>>((ref) => []);

final truekeMatchesProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final hiddenTruekes = ref.watch(hiddenTruekesProvider);
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;

  return productsAsync.whenData((products) {
    if (currentUserId == null) return [];
    
    final myProducts = products.where((p) => p.ownerId == currentUserId).toList();
    final otherProducts = products.where((p) => p.ownerId != currentUserId).toList();
    
    List<Map<String, dynamic>> truekes = [];

    for (var myProduct in myProducts) {
      for (var otherProduct in otherProducts) {
        final myWanted = _normalize(myProduct.wanted);
        final otherTitle = _normalize(otherProduct.title);
        
        final otherWanted = _normalize(otherProduct.wanted);
        final myTitle = _normalize(myProduct.title);

        if (myWanted.isNotEmpty && otherWanted.isNotEmpty &&
            (otherTitle.contains(myWanted) || myWanted.contains(otherTitle)) &&
            (myTitle.contains(otherWanted) || otherWanted.contains(myTitle))) {
          
          final matchId = '${myProduct.id}-${otherProduct.id}';
          if (!hiddenTruekes.contains(matchId)) {
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
