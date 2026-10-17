import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_search_provider.dart';
import '../../../home/widgets/product_card.dart';
import '../../../../models/product.dart';

class ProductSearchScreen extends ConsumerStatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  ConsumerState<ProductSearchScreen> createState() =>
      _ProductSearchScreenState();
}

class _ProductSearchScreenState extends ConsumerState<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(productSearchNotifierProvider.notifier)
          .initializePositionWithGPS();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, ProductSearchNotifier notifier) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      notifier.updateQuery(query);
      notifier.search();
    });
  }

  String _getTradeTypeLabel(TradeType type) {
    switch (type) {
      case TradeType.trade:
        return 'Trueque puro';
      case TradeType.sale:
        return 'Venta directa';
      case TradeType.tradeAndMoney:
        return 'Trueque + €';
    }
  }

  Widget _buildActiveChip(
    BuildContext context,
    String label,
    VoidCallback onDelete,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersRow(
    BuildContext context,
    ProductSearchState state,
    ProductSearchNotifier notifier,
  ) {
    final List<Widget> activeChips = [];
    if (state.selectedCategory != null) {
      activeChips.add(
        _buildActiveChip(
          context,
          state.selectedCategory!,
          () => notifier.toggleCategory(null),
        ),
      );
    }
    if (state.selectedTradeType != null) {
      activeChips.add(
        _buildActiveChip(
          context,
          _getTradeTypeLabel(state.selectedTradeType!),
          () => notifier.updateTradeType(null),
        ),
      );
    }
    if (state.selectedCondition != null) {
      activeChips.add(
        _buildActiveChip(
          context,
          'Estado: ${state.selectedCondition!}',
          () => notifier.updateCondition(null),
        ),
      );
    }
    if (state.minPrice > 0.0 || state.maxPrice < 1000.0) {
      activeChips.add(
        _buildActiveChip(
          context,
          '${state.minPrice.round()}€ - ${state.maxPrice.round()}€',
          () => notifier.updatePriceRange(0.0, 1000.0),
        ),
      );
    }
    if (state.maxRadiusKm != 15.0) {
      activeChips.add(
        _buildActiveChip(context, 'Radio: ${state.maxRadiusKm.round()} km', () {
          notifier.updateRadius(15.0);
          notifier.search();
        }),
      );
    }
    if (activeChips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: activeChips.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) => activeChips[index],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    ProductSearchState state,
    ProductSearchNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtros Avanzados',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rango de Precio',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  RangeSlider(
                    values: RangeValues(state.minPrice, state.maxPrice),
                    min: 0.0,
                    max: 1000.0,
                    divisions: 20,
                    labels: RangeLabels(
                      '${state.minPrice.round()}€',
                      '${state.maxPrice.round()}€',
                    ),
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: theme.colorScheme.primary.withAlpha(50),
                    onChanged: (RangeValues values) {
                      setModalState(() {
                        notifier.updatePriceRange(values.start, values.end);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Radio de Búsqueda (${state.maxRadiusKm.round()} km)',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Slider(
                    value: state.maxRadiusKm,
                    min: 1.0,
                    max: 100.0,
                    divisions: 99,
                    label: '${state.maxRadiusKm.round()} km',
                    activeColor: theme.colorScheme.primary,
                    onChanged: (value) {
                      setModalState(() {
                        notifier.updateRadius(value);
                      });
                    },
                    onChangeEnd: (value) {
                      notifier.search();
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tipo de Trato',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: TradeType.values.map((type) {
                      return ChoiceChip(
                        label: Text(_getTradeTypeLabel(type)),
                        selected: state.selectedTradeType == type,
                        onSelected: (selected) {
                          setModalState(() {
                            notifier.updateTradeType(selected ? type : null);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Aplicar Filtros'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResultsSection(ProductSearchState searchState) {
    return searchState.products.when(
      data: (products) {
        if (products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 80),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: Colors.black26,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No hemos encontrado artículos',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.64,
          ),
          itemBuilder: (context, index) =>
              ProductCard(product: products[index]),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 80),
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(productSearchNotifierProvider);
    final searchNotifier = ref.read(productSearchNotifierProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Explorar',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
            onPressed: () =>
                _showFilterBottomSheet(context, searchState, searchNotifier),
          ),
          TextButton(
            onPressed: () {
              _searchController.clear();
              searchNotifier.clearAllFilters();
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => _onSearchChanged(value, searchNotifier),
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15),
            decoration: InputDecoration(
              hintText: '¿Qué estás buscando?',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: 22,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        searchNotifier.updateQuery('');
                        searchNotifier.search();
                        setState(() {});
                      },
                      child: const Icon(
                        Icons.clear_rounded,
                        color: Colors.black45,
                        size: 18,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          _buildActiveFiltersRow(context, searchState, searchNotifier),
          const SizedBox(height: 8),
          _buildResultsSection(searchState),
        ],
      ),
    );
  }
}
