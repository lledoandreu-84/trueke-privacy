import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/product_model.dart';

enum ProductSortOption { relevance, priceAsc, priceDesc, distance }

class ProductFilters {
  const ProductFilters({
    this.query = '',
    this.category,
    this.tradeType,
    this.userLatitude,
    this.userLongitude,
    this.radiusInKm = 50.0,
    this.sortBy = ProductSortOption.relevance,
    this.minPrice,
    this.maxPrice,
    this.condition,
    this.page = 0,
  });

  final String query;
  final String? category;
  final String? tradeType;
  final double? userLatitude;
  final double? userLongitude;
  final double radiusInKm;
  final ProductSortOption sortBy;
  final double? minPrice;
  final double? maxPrice;
  final String? condition;
  final int page;

  bool get isPriceRangeInvalid {
    if (minPrice != null && maxPrice != null) {
      return minPrice! > maxPrice!;
    }
    return false;
  }

  bool get hasActiveFilters =>
      query.isNotEmpty ||
      category != null ||
      tradeType != null ||
      sortBy != ProductSortOption.relevance ||
      minPrice != null ||
      maxPrice != null ||
      condition != null;

  // Modificado con lógica explícita para permitir setear campos a null de forma segura
  ProductFilters copyWith({
    String? query,
    String? Function()? category,
    String? Function()? tradeType,
    double? userLatitude,
    double? userLongitude,
    double? radiusInKm,
    ProductSortOption? sortBy,
    double? minPrice,
    double? maxPrice,
    String? condition,
    int? page,
  }) {
    return ProductFilters(
      query: query ?? this.query,
      category: category != null ? category() : this.category,
      tradeType: tradeType != null ? tradeType() : this.tradeType,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      radiusInKm: radiusInKm ?? this.radiusInKm,
      sortBy: sortBy ?? this.sortBy,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      condition: condition ?? this.condition,
      page: page ?? this.page,
    );
  }
}

class ProductFiltersNotifier extends Notifier<ProductFilters> {
  @override
  ProductFilters build() => const ProductFilters();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setCategory(String? category) =>
      state = state.copyWith(category: () => category);

  void setTradeType(String? tradeType) =>
      state = state.copyWith(tradeType: () => tradeType);

  void setPage(int page) => state = state.copyWith(page: page);

  void toggleCategory(String category) {
    if (state.category == category) {
      state = state.copyWith(category: () => null);
    } else {
      state = state.copyWith(category: () => category);
    }
  }

  void incrementPage() => state = state.copyWith(page: state.page + 1);

  void updateSortBy(dynamic sortByOption) {
    if (sortByOption is ProductSortOption) {
      state = state.copyWith(sortBy: sortByOption);
    } else if (sortByOption is String) {
      final normalizedInput = sortByOption.replaceAll('_', '').toLowerCase();
      final parsed = ProductSortOption.values.firstWhere((e) {
        final enumName = e.name.toLowerCase();
        return enumName == normalizedInput;
      }, orElse: () => ProductSortOption.relevance);
      state = state.copyWith(sortBy: parsed);
    }
  }

  void updateCondition(String? condition) =>
      state = state.copyWith(condition: condition);
  void updatePriceRange(double? min, double? max) =>
      state = state.copyWith(minPrice: min, maxPrice: max);

  void updateLocation(double? lat, double? lng) {
    state = state.copyWith(userLatitude: lat, userLongitude: lng);
  }

  void setGeoFilter({
    required double latitude,
    required double longitude,
    required double radiusInKm,
  }) {
    state = state.copyWith(
      userLatitude: latitude,
      userLongitude: longitude,
      radiusInKm: radiusInKm,
    );
  }

  void clearGeoFilter() {
    state = state.copyWith(userLatitude: null, userLongitude: null);
  }

  void updateMaxDistance(double distance) {
    state = state.copyWith(radiusInKm: distance);
  }

  void clear() => state = const ProductFilters();
  void clearFilters() => state = const ProductFilters();
}

final productFiltersProvider =
    NotifierProvider<ProductFiltersNotifier, ProductFilters>(() {
      return ProductFiltersNotifier();
    });

final filteredProductsProvider = FutureProvider.autoDispose<List<Product>>((
  ref,
) async {
  final filters = ref.watch(productFiltersProvider);
  if (filters.isPriceRangeInvalid) {
    return const [];
  }
  return const [];
});
