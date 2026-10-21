import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_search_provider.dart';
import '../../../home/widgets/product_card.dart';
import '../../../../models/product.dart';
import '../../../../core/theme/app_colors.dart';

class ProductSearchScreen extends ConsumerStatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  ConsumerState<ProductSearchScreen> createState() =>
      _ProductSearchScreenState();
}

class _ProductSearchScreenState extends ConsumerState<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  final List<double> _distanceTiers = [
    25.0,
    50.0,
    100.0,
    150.0,
    200.0,
    250.0,
    9999.0,
  ];

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

  String _getDistanceLabel(double km) {
    if (km >= 9999.0) return 'Sin límite';
    return '${km.round()} km';
  }

  Widget _buildActiveChip(
    BuildContext context,
    String label,
    VoidCallback onDelete,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primary,
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
    if (state.minPrice > 0.0 || state.maxPrice < 5000.0) {
      activeChips.add(
        _buildActiveChip(
          context,
          '${state.minPrice.round()}€ - ${state.maxPrice.round()}€',
          () => notifier.updatePriceRange(0.0, 5000.0),
        ),
      );
    }
    if (state.maxRadiusKm < 9900.0) {
      activeChips.add(
        _buildActiveChip(
          context,
          'Ubicación: ${_getDistanceLabel(state.maxRadiusKm)}',
          () {
            notifier.updateRadius(9999.0);
          },
        ),
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
    ProductSearchState initialModalState,
    ProductSearchNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(productSearchNotifierProvider);

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filtros Avanzados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Rango de Precio (€)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    RangeSlider(
                      values: RangeValues(state.minPrice, state.maxPrice),
                      min: 0.0,
                      max: 5000.0,
                      divisions: 50,
                      labels: RangeLabels(
                        '${state.minPrice.round()}€',
                        '${state.maxPrice.round()}€',
                      ),
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.surfaceMint,
                      onChanged: (RangeValues values) {
                        notifier.updatePriceRange(values.start, values.end);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ubicación y Proximidad (Distancia)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _distanceTiers.map((tier) {
                        final isSelected = state.maxRadiusKm == tier;
                        return ChoiceChip(
                          label: Text(_getDistanceLabel(tier)),
                          selected: isSelected,
                          selectedColor: AppColors.surfaceMint,
                          backgroundColor: AppColors.background,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              notifier.updateRadius(tier);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Estado del Producto',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          ['Nuevo', 'Poco uso', 'Buen estado', 'Muy usado'].map(
                            (condition) {
                              final isSelected =
                                  state.selectedCondition == condition;
                              return ChoiceChip(
                                label: Text(condition),
                                selected: isSelected,
                                selectedColor: AppColors.surfaceMint,
                                backgroundColor: AppColors.background,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                onSelected: (selected) {
                                  notifier.updateCondition(
                                    selected ? condition : null,
                                  );
                                },
                              );
                            },
                          ).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tipo de Trato',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: TradeType.values.map((type) {
                        final isSelected = state.selectedTradeType == type;
                        String label = type.name;
                        if (type.name == 'trade') {
                          label = 'Trueque puro';
                        } else if (type.name == 'sale')
                          label = 'Venta directa';
                        else if (type.name == 'tradeAndCash' ||
                            type.name == 'tradeAndMoney')
                          label = 'Trueque + €';
                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          selectedColor: AppColors.surfaceMint,
                          backgroundColor: AppColors.background,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            notifier.updateTradeType(selected ? type : null);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Aplicar Filtros',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No hemos encontrado artículos',
                    style: TextStyle(
                      color: AppColors.textSecondary,
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
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Text(
            'Error: $err',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(productSearchNotifierProvider);
    final searchNotifier = ref.read(productSearchNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Explorar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
            onPressed: () =>
                _showFilterBottomSheet(context, searchState, searchNotifier),
          ),
          TextButton(
            onPressed: () {
              _searchController.clear();
              searchNotifier.clearAllFilters();
            },
            child: const Text(
              'Limpiar',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
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
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: '¿Qué estás buscando?',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 15,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        searchNotifier.updateQuery('');
                        setState(() {});
                      },
                      child: const Icon(
                        Icons.clear_rounded,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceMint.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
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
