require 'fileutils'

provider_content = <<~DART
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'products_provider.dart';

// Función para normalizar texto (elimina acentos, pasa a minúsculas y quita caracteres especiales)
String _normalize(String text) {
  return text.toLowerCase()
    .replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u')
    .replaceAll('v', 'b') // Homologar b y v
    .replaceAll('h', '')  // Ignorar h
    .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
    .trim();
}

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
        final myWanted = _normalize(myProduct.wanted);
        final otherTitle = _normalize(otherProduct.title);
        
        final otherWanted = _normalize(otherProduct.wanted);
        final myTitle = _normalize(myProduct.title);

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
