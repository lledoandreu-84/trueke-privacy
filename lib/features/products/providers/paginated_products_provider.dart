import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/product.dart';
import 'product_filters_provider.dart';
import 'product_repository_provider.dart';

class PaginatedProductsState {
  final List<Product> products;
  final bool isLoadingMore;
  final bool hasReachedEnd;

  const PaginatedProductsState({
    required this.products,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
  });

  PaginatedProductsState copyWith({
    List<Product>? products,
    bool? isLoadingMore,
    bool? hasReachedEnd,
  }) {
    return PaginatedProductsState(
      products: products ?? this.products,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}

class PaginatedProductsNotifier extends AsyncNotifier<PaginatedProductsState> {
  static const String _cacheKey = 'cached_feed_products_v4';

  @override
  Future<PaginatedProductsState> build() async {
    final filters = ref.watch(productFiltersProvider);
    final repository = ref.watch(productRepositoryProvider);

    try {
      final initialItems = await repository.getProducts(
        query: filters.query,
        category: filters.category,
        userLatitude: filters.userLatitude,
        userLongitude: filters.userLongitude,
        radiusInKm: filters.radiusInKm,
        page: 0,
        limit: 20,
      );

      final filteredList = _applyLocalFilters(initialItems, filters);

      // Persistencia asíncrona de fondo sin bloquear el hilo principal de renderizado
      unawaited(_saveCache(filteredList));

      return PaginatedProductsState(
        products: filteredList,
        hasReachedEnd: initialItems.length < 20,
      );
    } catch (e) {
      // Mecanismo de Recuperación Defensiva (Fallback Offline)
      final cachedItems = await _loadCache();
      if (cachedItems.isNotEmpty) {
        final filteredList = _applyLocalFilters(cachedItems, filters);
        return PaginatedProductsState(
          products: filteredList,
          hasReachedEnd: true, // Forzar fin de paginación simulado en offline
        );
      }
      rethrow;
    }
  }

  Future<void> _saveCache(List<Product> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheableItems = items
          .where((product) => !product.id.startsWith('mock_'))
          .toList();
      final String rawJson = jsonEncode(
        cacheableItems.map((product) => product.toJson()).toList(),
      );
      await prefs.setString(_cacheKey, rawJson);
    } catch (_) {
      // Silenciar errores de escritura de caché para no comprometer la experiencia de usuario
    }
  }

  Future<List<Product>> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? rawJson = prefs.getString(_cacheKey);
      if (rawJson == null) return [];

      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .where((product) => !product.id.startsWith('mock_'))
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<Product> _applyLocalFilters(List<Product> items, dynamic filters) {
    final processedList = items.where((product) {
      final matchesTradeType =
          filters.tradeType == null || product.tradeType == filters.tradeType;

      final matchesCondition =
          filters.condition == null || product.condition == filters.condition;

      if (product.price != null) {
        if (filters.minPrice != null && product.price! < filters.minPrice!) {
          return false;
        }
        if (filters.maxPrice != null && product.price! > filters.maxPrice!) {
          return false;
        }
      }
      return matchesTradeType && matchesCondition;
    }).toList();

    switch (filters.sortBy) {
      case ProductSortOption.relevance:
        processedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ProductSortOption.priceAsc:
        processedList.sort((a, b) {
          if (a.price == null && b.price == null) return 0;
          if (a.price == null) return 1;
          if (b.price == null) return -1;
          return a.price!.compareTo(b.price!);
        });
        break;
      case ProductSortOption.priceDesc:
        processedList.sort((a, b) {
          if (a.price == null && b.price == null) return 0;
          if (a.price == null) return 1;
          if (b.price == null) return -1;
          return b.price!.compareTo(a.price!);
        });
        break;
      case ProductSortOption.distance:
        if (filters.userLatitude != null && filters.userLongitude != null) {
          final double uLat = filters.userLatitude!;
          final double uLng = filters.userLongitude!;

          double haversineDistance(
            double lat1,
            double lon1,
            double lat2,
            double lon2,
          ) {
            const double earthRadiusInMeters = 6371000;
            final double dLat = (lat2 - lat1) * math.pi / 180.0;
            final double dLon = (lon2 - lon1) * math.pi / 180.0;
            final double rLat1 = lat1 * math.pi / 180.0;
            final double rLat2 = lat2 * math.pi / 180.0;

            final double a =
                math.sin(dLat / 2) * math.sin(dLat / 2) +
                math.sin(dLon / 2) *
                    math.sin(dLon / 2) *
                    math.cos(rLat1) *
                    math.cos(rLat2);
            final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

            return earthRadiusInMeters * c;
          }

          processedList.sort((a, b) {
            if (a.latitude == null || a.longitude == null) return 1;
            if (b.latitude == null || b.longitude == null) return -1;

            final double distA = haversineDistance(
              uLat,
              uLng,
              a.latitude!,
              a.longitude!,
            );
            final double distB = haversineDistance(
              uLat,
              uLng,
              b.latitude!,
              b.longitude!,
            );
            return distA.compareTo(distB);
          });
        }
        break;
    }
    return processedList;
  }

  Future<void> loadNextPage() async {
    final currentAsyncState = state;
    if (currentAsyncState.isLoading ||
        currentAsyncState.isRefreshing ||
        currentAsyncState.hasError) {
      return;
    }

    final currentState = currentAsyncState.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        currentState.hasReachedEnd) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final filters = ref.read(productFiltersProvider);
      final repository = ref.read(productRepositoryProvider);
      final nextPage = filters.page + 1;

      final newItems = await repository.getProducts(
        query: filters.query,
        category: filters.category,
        userLatitude: filters.userLatitude,
        userLongitude: filters.userLongitude,
        radiusInKm: filters.radiusInKm,
        page: nextPage,
        limit: 20,
      );

      ref.read(productFiltersProvider.notifier).incrementPage();
      final processedNewItems = _applyLocalFilters(newItems, filters);

      state = AsyncValue.data(
        PaginatedProductsState(
          products: [...currentState.products, ...processedNewItems],
          isLoadingMore: false,
          hasReachedEnd: newItems.length < 20,
        ),
      );
    } catch (error) {
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
    }
  }
}

final paginatedProductsProvider =
    AsyncNotifierProvider.autoDispose<
      PaginatedProductsNotifier,
      PaginatedProductsState
    >(PaginatedProductsNotifier.new);
