import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product.dart';
import '../../../core/services/location_service.dart';
import 'product_repository_provider.dart';

class ProductSearchState {
  final String query;
  final double maxRadiusKm;
  final double latitude;
  final double longitude;
  final String? selectedCondition;
  final String? selectedCategory;
  final TradeType? selectedTradeType;
  final double minPrice;
  final double maxPrice;
  final AsyncValue<List<Product>> products;

  const ProductSearchState({
    required this.query,
    required this.maxRadiusKm,
    required this.latitude,
    required this.longitude,
    this.selectedCondition,
    this.selectedCategory,
    this.selectedTradeType,
    required this.minPrice,
    required this.maxPrice,
    required this.products,
  });

  ProductSearchState copyWith({
    String? query,
    double? maxRadiusKm,
    double? latitude,
    double? longitude,
    String? selectedCondition,
    bool clearCondition = false,
    String? selectedCategory,
    bool clearCategory = false,
    TradeType? selectedTradeType,
    bool clearTradeType = false,
    double? minPrice,
    double? maxPrice,
    AsyncValue<List<Product>>? products,
  }) {
    return ProductSearchState(
      query: query ?? this.query,
      maxRadiusKm: maxRadiusKm ?? this.maxRadiusKm,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      selectedCondition: clearCondition
          ? null
          : (selectedCondition ?? this.selectedCondition),
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      selectedTradeType: clearTradeType
          ? null
          : (selectedTradeType ?? this.selectedTradeType),
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      products: products ?? this.products,
    );
  }
}

class ProductSearchNotifier extends Notifier<ProductSearchState> {
  @override
  ProductSearchState build() {
    return const ProductSearchState(
      query: '',
      maxRadiusKm: 50.0,
      latitude: 40.416775,
      longitude: -3.703790,
      selectedCondition: null,
      selectedCategory: null,
      selectedTradeType: null,
      minPrice: 0.0,
      maxPrice: 5000.0,
      products: AsyncValue.data([]),
    );
  }

  String _normalize(String input) {
    var letters = {
      'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
      'à': 'a', 'è': 'e', 'ì': 'i', 'ò': 'o', 'ù': 'u',
      'ä': 'a', 'ë': 'e', 'ï': 'i', 'ö': 'o', 'ü': 'u',
      'ñ': 'n',
    };
    String result = input.toLowerCase();
    letters.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }

  Future<void> initializePositionWithGPS() async {
    try {
      final position = await LocationService().getCurrentLocation();
      if (position != null) {
        state = state.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        await search();
      }
    } catch (_) {}
  }

  Future<void> search() async {
    state = state.copyWith(products: const AsyncValue.loading());

    try {
      final repository = ref.read(productRepositoryProvider);
      final isUnlimited = state.maxRadiusKm >= 9999.0;
      final radiusMeters = isUnlimited ? 9999999.0 : state.maxRadiusKm * 1000.0;

      final results = await repository.searchProductsAdvanced(
        query: state.query,
        longitude: state.longitude,
        latitude: state.latitude,
        maxRadiusMeters: radiusMeters,
      );

      final normalizedQuery = _normalize(state.query.trim());

      final filteredResults = results.where((product) {
        if (normalizedQuery.isNotEmpty) {
          final titleMatch = _normalize(product.title).contains(normalizedQuery);
          final descMatch = _normalize(product.description).contains(normalizedQuery);
          final catMatch = _normalize(product.category).contains(normalizedQuery);
          if (!titleMatch && !descMatch && !catMatch) {
            return false;
          }
        }

        if (state.selectedCondition != null &&
            state.selectedCondition!.isNotEmpty) {
          final prodCondition = _normalize(product.condition);
          final targetCondition = _normalize(state.selectedCondition!);
          if (!prodCondition.contains(targetCondition)) {
            return false;
          }
        }

        if (state.selectedCategory != null &&
            state.selectedCategory!.isNotEmpty) {
          if (_normalize(product.category) != _normalize(state.selectedCategory!)) {
            return false;
          }
        }

        if (state.selectedTradeType != null) {
          if (product.tradeType != state.selectedTradeType) {
            return false;
          }
        }

        if (product.price != null) {
          if (product.price! < state.minPrice ||
              product.price! > state.maxPrice) {
            return false;
          }
        }

        return true;
      }).toList();

      state = state.copyWith(products: AsyncValue.data(filteredResults));
    } catch (e, stack) {
      state = state.copyWith(products: AsyncValue.error(e, stack));
    }
  }

  void updateQuery(String newQuery) {
    state = state.copyWith(query: newQuery);
    search();
  }

  void updateRadius(double newRadiusKm) {
    state = state.copyWith(maxRadiusKm: newRadiusKm);
    search();
  }

  void updateLocation(double lat, double lon) {
    state = state.copyWith(latitude: lat, longitude: lon);
    search();
  }

  void updateCondition(String? condition) {
    if (condition == null || condition.isEmpty) {
      state = state.copyWith(clearCondition: true);
    } else {
      state = state.copyWith(selectedCondition: condition);
    }
    search();
  }

  void toggleCategory(String? category) {
    if (category == null || state.selectedCategory == category) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
    search();
  }

  void updateTradeType(TradeType? type) {
    if (type == null) {
      state = state.copyWith(clearTradeType: true);
    } else {
      state = state.copyWith(selectedTradeType: type);
    }
    search();
  }

  void updatePriceRange(double min, double max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
    search();
  }

  void clearAllFilters() {
    state = state.copyWith(
      query: '',
      maxRadiusKm: 50.0,
      clearCondition: true,
      clearCategory: true,
      clearTradeType: true,
      minPrice: 0.0,
      maxPrice: 5000.0,
    );
    search();
  }
}

final productSearchNotifierProvider =
    NotifierProvider<ProductSearchNotifier, ProductSearchState>(() {
      return ProductSearchNotifier();
    });
