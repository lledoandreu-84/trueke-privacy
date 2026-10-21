import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/product.dart';
import '../../providers/product_search_provider.dart';
import 'package:trueke/features/home/widgets/product_card.dart';

class ProductSearchScreen extends ConsumerStatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  ConsumerState<ProductSearchScreen> createState() =>
      _ProductSearchScreenState();
}

class _ProductSearchScreenState extends ConsumerState<ProductSearchScreen> {
  late final TextEditingController _searchController;
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
    final initialQuery = ref.read(productSearchNotifierProvider).query;
    _searchController = TextEditingController(text: initialQuery);

    Future.microtask(() {
      ref
          .read(productSearchNotifierProvider.notifier)
          .initializePositionWithGPS();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(productSearchNotifierProvider.notifier).updateQuery(value);
  }

  String _getDistanceLabel(double km) {
    if (km >= 9900.0) return 'Sin límite';
    return '${km.round()} km';
  }

  Widget _buildActiveChip(
    BuildContext context,
    String label,
    VoidCallback onDeleted,
  ) {
    return InputChip(
      label: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppColors.surfaceMint,
      deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.primary),
      onDeleted: onDeleted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.transparent),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  Widget _buildActiveFiltersRow(
    BuildContext context,
    ProductSearchState state,
    ProductSearchNotifier notifier,
  ) {
    final activeChips = <Widget>[];

    if (state.selectedCondition != null &&
        state.selectedCondition!.isNotEmpty) {
      activeChips.add(
        _buildActiveChip(context, 'Estado: ${state.selectedCondition}', () {
          notifier.updateCondition(null);
        }),
      );
    }

    if (state.selectedCategory != null && state.selectedCategory!.isNotEmpty) {
      activeChips.add(
        _buildActiveChip(context, 'Cat: ${state.selectedCategory}', () {
          notifier.toggleCategory(null);
        }),
      );
    }

    if (state.selectedTradeType != null) {
      String label = state.selectedTradeType!.name;
      if (state.selectedTradeType == TradeType.trade) {
        label = 'Trueque puro';
      } else if (state.selectedTradeType == TradeType.sale) {
        label = 'Venta directa';
      } else {
        label = 'Trueque + €';
      }
      activeChips.add(
        _buildActiveChip(context, 'Trato: $label', () {
          notifier.updateTradeType(null);
        }),
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
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: _distanceTiers.map((tier) {
                        final isSelected = state.maxRadiusKm == tier;
                        return ChoiceChip(
                          showCheckmark: false,
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
                                showCheckmark: false,
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
                        if (type == TradeType.trade) {
                          label = 'Trueque puro';
                        } else if (type == TradeType.sale) {
                          label = 'Venta directa';
                        } else {
                          label = 'Trueque + €';
                        }
                        return ChoiceChip(
                          showCheckmark: false,
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

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(productSearchNotifierProvider);
    final searchNotifier = ref.read(productSearchNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Explorar',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '¿Qué estás buscando?',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildActiveFiltersRow(context, searchState, searchNotifier),
            Expanded(
              child: searchState.products.when(
                data: (products) {
                  if (searchState.query.trim().isEmpty) {
                    return const Center(
                      child: Text(
                        'Escribe algo para buscar productos',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  if (products.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No hemos encontrado artículos',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: products[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Text(
                    'Error al cargar productos: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
