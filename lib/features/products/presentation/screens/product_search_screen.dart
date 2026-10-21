import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/core/theme/app_colors.dart';
import 'package:trueke/app/routes/app_routes.dart';
import 'package:trueke/features/products/providers/product_filters_provider.dart';
import 'package:trueke/features/products/providers/paginated_products_provider.dart';
import 'package:trueke/features/home/widgets/product_card.dart';

class ProductSearchScreen extends ConsumerStatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  ConsumerState<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends ConsumerState<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final List<String> _categories = ['Todos', 'Electrónica', 'Moda', 'Hogar', 'Gaming', 'Deporte', 'Otros'];
  final List<double?> _radii = [25.0, 50.0, 100.0, 150.0, 200.0, 250.0, null];
  final List<String> _conditions = ['Nuevo', 'Poco uso', 'Buen estado', 'Muy usado'];
  final List<String> _tradeTypes = ['Trueke puro', 'Venta directa', 'Trueke + €'];

  // Escala de precios exacta solicitada
  final List<double> _priceSteps = [
    0, 5, 10, 15, 20, 25,
    50, 75, 100,
    150, 200, 300, 400, 500,
    1000, 2000, 3000, 4000, 5000
  ];

  @override
  void initState() {
    super.initState();
    final filters = ref.read(productFiltersProvider);
    _searchController.text = filters.query;
    _priceController.text = (filters.maxPrice ?? 5000.0).toInt().toString();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double _getClosestPriceIndex(double price) {
    int closestIndex = 0;
    double minDiff = double.infinity;
    for (int i = 0; i < _priceSteps.length; i++) {
      double diff = (_priceSteps[i] - price).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestIndex = i;
      }
    }
    return closestIndex.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(productFiltersProvider);
    final paginatedAsync = ref.watch(paginatedProductsProvider);
    final currentMaxPrice = filters.maxPrice ?? 5000.0;
    final sliderIndex = _getClosestPriceIndex(currentMaxPrice);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Explorar',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(paginatedProductsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🔍 Barra de Búsqueda
            TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(productFiltersProvider.notifier).setQuery(value);
              },
              decoration: InputDecoration(
                hintText: '¿Qué estás buscando?',
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(productFiltersProvider.notifier).setQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🎛️ Contenedor de Filtros Avanzados
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera del panel con botón dinámico de "Limpiar filtros"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtros de Búsqueda',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (filters.hasActiveFilters)
                        TextButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            _priceController.text = '5000';
                            ref.read(productFiltersProvider.notifier).clearFilters();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 14, color: AppColors.primary),
                          label: const Text(
                            'Limpiar filtros',
                            style: TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w700),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),

                  // 🏷️ Categoría
                  const Text(
                    'Categoría',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final isSelected = category == 'Todos'
                          ? filters.category == null
                          : filters.category == category;

                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: AppColors.surfaceMint,
                        backgroundColor: AppColors.background,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (selected) {
                          ref.read(productFiltersProvider.notifier).setCategory(
                                category == 'Todos' ? null : category,
                              );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 📍 Ubicación y Proximidad (Distancia)
                  const Text(
                    'Ubicación y Proximidad (Distancia)',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _radii.map((radius) {
                      final isSelected = radius == null
                          ? filters.radiusInKm >= 999.0
                          : filters.radiusInKm == radius;
                      final label = radius == null ? 'Sin límite' : '${radius.toInt()} km';

                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: AppColors.surfaceMint,
                        backgroundColor: AppColors.background,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (selected) {
                          ref.read(productFiltersProvider.notifier).updateMaxDistance(radius ?? 1000.0);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 💶 Rango de Precio (€)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rango de Precio (€)',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        width: 90,
                        height: 32,
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            suffixText: '€',
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                          onSubmitted: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null) {
                              final clamped = parsed.clamp(0.0, 5000.0);
                              ref.read(productFiltersProvider.notifier).updatePriceRange(filters.minPrice, clamped);
                              _priceController.text = clamped.toInt().toString();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Slider(
                    value: sliderIndex,
                    min: 0.0,
                    max: (_priceSteps.length - 1).toDouble(),
                    divisions: _priceSteps.length - 1,
                    activeColor: AppColors.primary,
                    inactiveColor: const Color(0xFFE2E8F0),
                    label: '${currentMaxPrice.toInt()} €',
                    onChanged: (value) {
                      final selectedPrice = _priceSteps[value.round()];
                      _priceController.text = selectedPrice.toInt().toString();
                      ref.read(productFiltersProvider.notifier).updatePriceRange(filters.minPrice, selectedPrice);
                    },
                  ),
                  const SizedBox(height: 12),

                  // ✨ Estado del Producto
                  const Text(
                    'Estado del Producto',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _conditions.map((condition) {
                      final isSelected = filters.condition == condition;
                      return ChoiceChip(
                        label: Text(condition),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: AppColors.surfaceMint,
                        backgroundColor: AppColors.background,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (selected) {
                          final newValue = isSelected ? null : condition;
                          ref.read(productFiltersProvider.notifier).updateCondition(newValue);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 🤝 Tipo de Trato
                  const Text(
                    'Tipo de Trato',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tradeTypes.map((tradeType) {
                      final isSelected = filters.tradeType == tradeType;
                      return ChoiceChip(
                        label: Text(tradeType),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: AppColors.surfaceMint,
                        backgroundColor: AppColors.background,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (selected) {
                          final newValue = isSelected ? null : tradeType;
                          ref.read(productFiltersProvider.notifier).setTradeType(newValue);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 📦 Indicador de Resultados Dinámicos en Tiempo Real
            paginatedAsync.when(
              data: (state) {
                final count = state.products.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    'Mostrando $count ${count == 1 ? 'artículo encontrado' : 'artículos encontrados'}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),

            // 📦 Listado de Resultados
            paginatedAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Error al cargar productos: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
              data: (state) {
                final products = state.products;

                if (products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                          SizedBox(height: 16),
                          Text(
                            'No se encontraron artículos',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Prueba a cambiar los filtros o ampliar el radio de búsqueda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.product,
                          arguments: product,
                        );
                      },
                      child: ProductCard(product: product),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
