import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'products_provider.dart';

String _normalize(String text) {
  if (text.isEmpty) return '';
  String normalized = text.toLowerCase().trim();

  final withDiacritics = 'áéíóúüñ';
  final withoutDiacritics = 'aeiouun';
  for (int i = 0; i < withDiacritics.length; i++) {
    normalized = normalized.replaceAll(withDiacritics[i], withoutDiacritics[i]);
  }

  if (normalized.endsWith('ces')) {
    normalized = '${normalized.substring(0, normalized.length - 3)}z';
  } else if (normalized.endsWith('es')) {
    normalized = normalized.substring(0, normalized.length - 2);
  } else if (normalized.endsWith('s')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }

  return normalized;
}

bool _matchTokens(String wanted, String title) {
  if (wanted.isEmpty || title.isEmpty) return false;

  final wantedTokens = wanted
      .split(' ')
      .map((t) => _normalize(t))
      .where((t) => t.length > 2)
      .toList();
  final titleTokens = title
      .split(' ')
      .map((t) => _normalize(t))
      .where((t) => t.length > 2)
      .toList();

  for (var wToken in wantedTokens) {
    for (var tToken in titleTokens) {
      if (tToken.contains(wToken) || wToken.contains(tToken)) {
        return true;
      }
    }
  }
  return false;
}

final hiddenTruekesProvider = AsyncNotifierProvider<HiddenTruekesNotifier, List<String>>(() {
  return HiddenTruekesNotifier();
});

class HiddenTruekesNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('hidden_truekes') ?? [];
  }

  Future<void> hide(String id) async {
    final currentState = state.value ?? [];
    if (!currentState.contains(id)) {
      final newState = [...currentState, id];
      state = AsyncValue.data(newState);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('hidden_truekes', newState);
    }
  }

  Future<void> markAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final readList = prefs.getStringList('read_truekes') ?? [];
    if (!readList.contains(id)) {
      readList.add(id);
      await prefs.setStringList('read_truekes', readList);
      // Forzamos una reconstrucción para actualizar la UI
      ref.notifyListeners();
    }
  }
}

final truekeMatchesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final productsAsync = ref.watch(productsProvider);
  final hiddenAsync = ref.watch(hiddenTruekesProvider);
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;

  if (currentUserId == null) return [];
  
  final products = productsAsync.value ?? [];
  final hiddenTruekes = hiddenAsync.value ?? [];
  
  final prefs = await SharedPreferences.getInstance();
  final readList = prefs.getStringList('read_truekes') ?? [];

  final myProducts = products.where((p) => p.ownerId == currentUserId).toList();
  final otherProducts = products.where((p) => p.ownerId != currentUserId).toList();

  List<Map<String, dynamic>> truekes = [];

  for (var myProduct in myProducts) {
    for (var otherProduct in otherProducts) {
      if (_matchTokens(myProduct.wanted, otherProduct.title) &&
          _matchTokens(otherProduct.wanted, myProduct.title)) {
        final matchId = '${myProduct.id}-${otherProduct.id}';
        if (!hiddenTruekes.contains(matchId)) {
          truekes.add({
            'myProduct': myProduct,
            'truekeProduct': otherProduct,
            'matchId': matchId,
            'isRead': readList.contains(matchId),
          });
        }
      }
    }
  }
  return truekes;
});
