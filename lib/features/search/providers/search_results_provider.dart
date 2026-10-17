import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/features/products/providers/product_filters_provider.dart';
import 'package:trueke/features/search/providers/search_repository_provider.dart';

class SearchResultsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final filters = ref.watch(productFiltersProvider);
    final repository = ref.watch(searchRepositoryProvider);

    final jsonList = await repository.searchProducts(filters);

    return jsonList.map((json) => Product.fromJson(json)).toList();
  }
}

final searchResultsProvider =
    AsyncNotifierProvider.autoDispose<SearchResultsNotifier, List<Product>>(
      SearchResultsNotifier.new,
    );
