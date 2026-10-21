import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/core/theme/app_colors.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/features/products/providers/product_search_provider.dart';
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

  final List<Map<String, dynamic>> _categoriesData = [
    {
      'name': 'Electrónica',
      'icon': Icons.devices_rounded,
      'color': const Color(0xFFE0E7FF),
      'textColor': const Color(0xFF4338CA),
    },
    {
      'name': 'Moda',
      'icon': Icons.checkroom_rounded,
      'color': const Color(0xFFFCE7F3),
      'textColor': const Color(0xFFBE185D),
    },
    {
      'name': 'Hogar',
      'icon': Icons.chair_rounded,
      'color': const Color(0xFFFEF3C7),
      'textColor': const Color(0xFFB45309),
    },
    {
      'name': 'Gaming',
      'icon': Icons.sports_esports_rounded,
      'color': const Color(0xFFF3E8FF),
      'textColor': const Color(0xFF6B21A8),
    },
    {
      'name': 'Deporte',
      'icon': Icons.fitness_center_rounded,
      'color': const Color(0xFFD1FAE5),
      'textColor': const Color(0xFF047857),
    },
    {
      'name': 'Otros',
      'icon': Icons.widgets_rounded,
      'color': const Color(0xFFF1F5F9),
      'textColor': const Color(0xFF334155),
    },
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
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
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
            final productsCount = state.products.asData?.value.length ?? 0;

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
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => notifier.clearAllFilters(),
                              child: const Text(
                                'Restablecer',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
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
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(
                          Icons.euro_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Rango de Precio (€)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
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
                    const Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Ubicación y Proximidad (Distancia)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _distanceTiers.map((tier) {
                        final isSelected = state.maxRadiusKm == tier;
                        return SizedBox(
                          width: 86,
                          child: ChoiceChip(
                            showCheckmark: false,
                            label: Center(child: Text(_getDistanceLabel(tier))),
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
                              fontSize: 12,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                notifier.updateRadius(tier);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Estado del Producto',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                    const Row(
                      children: [
                        Icon(
                          Icons.handshake_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tipo de Trato',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
                        child: Text(
                          'Ver $productsCount artículos',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
        automaticallyImplyLeading: false,
        titleSpacing: 16.0,
        title: const Text(
          'Explorar',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 2.0),
            child: TextButton.icon(
              onPressed: () => _showFilterBottomSheet(context, searchState, searchNotifier),
              icon: const Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
              label: const Text(
                'Filtros',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _searchController.clear();
              searchNotifier.clearAllFilters();
            },
            child: const Text(
              'Limpiar',
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Volver',
          ),
        ],
      
            child: TextButton.icon(
              onPressed: () =>
                  _showFilterBottomSheet(context, searchState, searchNotifier),
              icon: const Icon(
                Icons.tune_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              label: const Text(
                'Filtros',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () {
                _searchController.clear();
                searchNotifier.clearAllFilters();
              },
              child: const Text(
                'Limpiar',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
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
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
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
            ),
            const SizedBox(height: 12),
            _buildActiveFiltersRow(context, searchState, searchNotifier),
            Expanded(
              child: searchState.products.when(
                data: (products) {
                  // Si no hay consulta ni filtros activos, se muestra la cuadrícula de Categorías Destacadas
                  final hasActiveFilter =
                      searchState.query.trim().isNotEmpty ||
                      searchState.selectedCategory != null ||
                      searchState.selectedCondition != null ||
                      searchState.selectedTradeType != null ||
                      searchState.maxRadiusKm < 9900.0 ||
                      searchState.minPrice > 0.0 ||
                      searchState.maxPrice < 5000.0;

                  if (!hasActiveFilter) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          const Text(
                            'Categorías destacadas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Explora por tipo de artículo',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 2.1,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: _categoriesData.length,
                            itemBuilder: (context, index) {
                              final cat = _categoriesData[index];
                              return Material(
                                color: cat['color'] as Color,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    searchNotifier.toggleCategory(
                                      cat['name'] as String,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          cat['icon'] as IconData,
                                          color: cat['textColor'] as Color,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            cat['name'] as String,
                                            style: TextStyle(
                                              color: cat['textColor'] as Color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No hemos encontrado artículos',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            searchState.query.isEmpty
                                ? 'Prueba seleccionando otra categoría'
                                : 'Intenta con otra palabra clave',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
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
