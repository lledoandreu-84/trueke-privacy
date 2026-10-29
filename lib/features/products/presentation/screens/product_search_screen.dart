import 'package:trueke/shared/widgets/custom_app_bar.dart';
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
  final List<double?> _radii = [25.0, 50.0, 100.0, 200.0, null];
  final List<String> _conditions = ['Todos', 'Nuevo', 'Poco uso', 'Buen estado', 'Muy usado'];
  final List<String> _tradeTypes = ['Todos', 'Trueke', 'Venta directa', 'Trueke + €'];

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
      appBar: const CustomAppBar(titleText: 'Explorar'),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(paginatedProductsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 🔍 Barra de Búsqueda Compacta
            TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(productFiltersProvider.notifier).setQuery(value);
              },
              decoration: InputDecoration(
                hintText: '¿Qué estás buscando?',
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(productFiltersProvider.notifier).setQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 🎛️ Filtros Avanzados Compactos con etiquetas superiores externas
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtros de Búsqueda',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
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
                          icon: const Icon(Icons.refresh_rounded, size: 13, color: AppColors.primary),
                          label: const Text(
                            'Limpiar',
                            style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),

                  // Fila 1: Categoría y Distancia (Etiquetas externas arriba)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 2, bottom: 4),
                              child: Text(
                                'Categoría',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              initialValue: filters.category ?? 'Todos',
                              dropdownColor: AppColors.surface,
                              isExpanded: true,
                              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (val) {
                                ref.read(productFiltersProvider.notifier).setCategory(val == 'Todos' ? null : val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 2, bottom: 4),
                              child: Text(
                                'Distancia',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                            DropdownButtonFormField<double?>(
                              initialValue: filters.radiusInKm >= 999.0 ? null : filters.radiusInKm,
                              dropdownColor: AppColors.surface,
                              isExpanded: true,
                              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: _radii.map((r) => DropdownMenuItem(value: r, child: Text(r == null ? 'Sin límite' : '${r.toInt()} km', overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (val) {
                                ref.read(productFiltersProvider.notifier).updateMaxDistance(val ?? 1000.0);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Fila 2: Estado y Trato (Etiquetas externas arriba)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 2, bottom: 4),
                              child: Text(
                                'Estado',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              initialValue: filters.condition ?? 'Todos',
                              dropdownColor: AppColors.surface,
                              isExpanded: true,
                              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: _conditions.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (val) {
                                ref.read(productFiltersProvider.notifier).updateCondition(val == 'Todos' ? null : val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 2, bottom: 4),
                              child: Text(
                                'Trato',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              initialValue: filters.tradeType ?? 'Todos',
                              dropdownColor: AppColors.surface,
                              isExpanded: true,
                              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: _tradeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (val) {
                                ref.read(productFiltersProvider.notifier).setTradeType(val == 'Todos' ? null : val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 💶 Rango de Precio con Campo Editable
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Precio máx:',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        width: 85,
                        height: 28,
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            suffixText: '€',
                            suffixStyle: const TextStyle(fontSize: 11, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide.none,
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
                  SizedBox(
                    height: 28,
                    child: Slider(
                      value: sliderIndex,
                      min: 0.0,
                      max: (_priceSteps.length - 1).toDouble(),
                      divisions: _priceSteps.length - 1,
                      activeColor: AppColors.primary,
                      inactiveColor: const Color(0xFFE2E8F0),
                      onChanged: (value) {
                        final selectedPrice = _priceSteps[value.round()];
                        _priceController.text = selectedPrice.toInt().toString();
                        ref.read(productFiltersProvider.notifier).updatePriceRange(filters.minPrice, selectedPrice);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 📦 Listado de Resultados
            paginatedAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error al cargar productos: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
              data: (state) {
                final products = state.products;

                if (products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 42, color: Color(0xFF94A3B8)),
                          SizedBox(height: 12),
                          Text(
                            'No se encontraron artículos',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Prueba a cambiar los filtros de búsqueda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
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
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.95,
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
