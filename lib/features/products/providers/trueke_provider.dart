import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'products_provider.dart';

String _normalize(String text) {
  if (text.isEmpty) return '';
  String normalized = text.toLowerCase().trim();
  
  if (normalized.endsWith('ces')) {
    normalized = '${normalized.substring(0, normalized.length - 3)}z';
  } else if (normalized.endsWith('es')) {
    normalized = normalized.substring(0, normalized.length - 2);
  } else if (normalized.endsWith('s')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  
  return normalized;
}


// Usamos un Provider simple que envuelve un ValueNotifier
final hiddenTruekesProvider = NotifierProvider<HiddenTruekesNotifier, List<String>>(() {
  return HiddenTruekesNotifier();
});

class HiddenTruekesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    load();
    return [];
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList('hidden_truekes') ?? [];
  }

  Future<void> hide(String id) async {
    if (!state.contains(id)) {
      state = [...state, id];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('hidden_truekes', state);
    }
  }
}


final truekeMatchesProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final hiddenNotifier = ref.watch(hiddenTruekesProvider);
  
  // Forzamos la lectura del valor actual
  final hiddenTruekes = hiddenNotifier;
  
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
