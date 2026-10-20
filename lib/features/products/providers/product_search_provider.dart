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
      maxRadiusKm: 15.0,
      latitude: 40.416775,
      longitude: -3.703790,
      selectedCondition: null,
      selectedCategory: null,
      selectedTradeType: null,
      minPrice: 0.0,
      maxPrice: 1000.0,
      products: AsyncValue.data([]),
    );
  }

  Future<void> initializePositionWithGPS() async {
    try {
      final position = await LocationService().getCurrentLocation();
      if (position != null) {
        state = state.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
    } catch (_) {
      // Fallback seguro: se mantienen las coordenadas por defecto de Madrid si falla
    }
  }

  Future<void> search() async {
    state = state.copyWith(products: const AsyncValue.loading());

    try {
      final repository = ref.read(productRepositoryProvider);
      final radiusMeters = state.maxRadiusKm * 1000.0;

      final results = await repository.searchProductsAdvanced(
        query: state.query,
        longitude: state.longitude,
        latitude: state.latitude,
        maxRadiusMeters: radiusMeters,
      );

      final queryLower = state.query.trim().toLowerCase();

      final filteredResults = results.where((product) {
        // Validación de término de búsqueda local robusto (soporta acentos y coincidencias parciales)
        if (queryLower.isNotEmpty) {
          final title = product.title.toLowerCase();
          final description = product.description.toLowerCase();
          if (!title.contains(queryLower) && !description.contains(queryLower)) {
            return false;
          }
        }

        if (state.selectedCondition != null &&
            state.selectedCondition!.isNotEmpty) {
          if (product.condition.toLowerCase() !=
              state.selectedCondition!.toLowerCase()) {
            return false;
          }
        }
        if (state.selectedCategory != null &&
            state.selectedCategory!.isNotEmpty) {
          if (product.category.toLowerCase() !=
              state.selectedCategory!.toLowerCase()) {
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

  void updateQuery(String newQuery) => state = state.copyWith(query: newQuery);
  void updateRadius(double newRadiusKm) =>
      state = state.copyWith(maxRadiusKm: newRadiusKm);
  void updateLocation(double lat, double lon) =>
      state = state.copyWith(latitude: lat, longitude: lon);

  void updateCondition(String? condition) {
    if (condition == null) {
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
      maxRadiusKm: 15.0,
      clearCondition: true,
      clearCategory: true,
      clearTradeType: true,
      minPrice: 0.0,
      maxPrice: 1000.0,
    );
    search();
  }
}

final productSearchNotifierProvider =
    NotifierProvider<ProductSearchNotifier, ProductSearchState>(() {
  return ProductSearchNotifier();
});
