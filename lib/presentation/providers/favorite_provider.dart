import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/supabase_favorite_repository.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../../models/product.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return SupabaseFavoriteRepository(Supabase.instance.client);
});

final favoriteIdsProvider = StreamProvider.family<List<String>, String>((
  ref,
  userId,
) {
  final repo = ref.watch(favoriteRepositoryProvider);
  return repo.watchFavoriteIds(userId);
});

final favoriteProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  userId,
) {
  final repo = ref.watch(favoriteRepositoryProvider);
  return repo.getFavoriteProducts(userId);
});

class FavoriteNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggle(String userId, String productId, bool isFavorite) async {
    final repo = ref.read(favoriteRepositoryProvider);
    await repo.toggleFavorite(userId, productId, isFavorite);
  }
}

final favoriteNotifierProvider =
    NotifierProvider.autoDispose<FavoriteNotifier, void>(
      () => FavoriteNotifier(),
    );
