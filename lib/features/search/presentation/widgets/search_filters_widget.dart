import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/products/providers/product_filters_provider.dart';

class SearchFiltersWidget extends ConsumerWidget {
  const SearchFiltersWidget({super.key});

  String _mapSortOptionToString(ProductSortOption option) {
    switch (option) {
      case ProductSortOption.priceAsc:
        return 'price_asc';
      case ProductSortOption.priceDesc:
        return 'price_desc';
      case ProductSortOption.distance:
        return 'distance';
      case ProductSortOption.relevance:
        return 'recent';
    }
  }

  ProductSortOption _mapStringToSortOption(String? val) {
    switch (val) {
      case 'price_asc':
        return ProductSortOption.priceAsc;
      case 'price_desc':
        return ProductSortOption.priceDesc;
      case 'distance':
        return ProductSortOption.distance;
      default:
        return ProductSortOption.relevance;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 18.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(productFiltersProvider);
    final filtersNotifier = ref.read(productFiltersProvider.notifier);
    final hasLocation =
        filters.userLatitude != null && filters.userLongitude != null;
    final conditionMap = {
      'Nuevo': 'Nuevo',
      'Como nuevo': 'Como nuevo',
      'Buen estado': 'Buen estado',
      'Con marcas de uso': 'Con marcas de uso',
      'Para reparar': 'Para reparar',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtros Avanzados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.4,
                  ),
                ),
                TextButton(
                  onPressed: () => filtersNotifier.clearFilters(),
                  style: TextButton.styleFrom(foregroundColor: Colors.black54),
                  child: const Text(
                    'Limpiar todo',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
              ],
            ),
            const Divider(height: 12, thickness: 0.5, color: Colors.black12),
            _buildSectionTitle('Ordenar por'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _mapSortOptionToString(filters.sortBy),
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black45,
                    size: 20,
                  ),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  items: [
                    const DropdownMenuItem(
                      value: 'recent',
                      child: Text('Más recientes'),
                    ),
                    const DropdownMenuItem(
                      value: 'price_asc',
                      child: Text('Precio: menor a mayor'),
                    ),
                    const DropdownMenuItem(
                      value: 'price_desc',
                      child: Text('Precio: mayor a menor'),
                    ),
                    if (hasLocation)
                      const DropdownMenuItem(
                        value: 'distance',
                        child: Text('Cercanía geográfica'),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      filtersNotifier.updateSortBy(
                        _mapStringToSortOption(value).name,
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Usar mi ubicación actual',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Switch.adaptive(
                  value: hasLocation,
                  activeThumbColor: Colors.black87,
                  activeTrackColor: Colors.black87,
                  inactiveTrackColor: const Color(0xFFE5E5EA),
                  onChanged: (value) {
                    if (value) {
                      filtersNotifier.updateLocation(40.416775, -3.703790);
                    } else {
                      filtersNotifier.updateLocation(null, null);
                      if (filters.sortBy == ProductSortOption.distance) {
                        filtersNotifier.updateSortBy(
                          ProductSortOption.relevance.name,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            if (hasLocation) ...[
              const SizedBox(height: 10),
              Text(
                'Distancia Máxima: ${filters.radiusInKm.round()} km',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.black87,
                  inactiveTrackColor: Colors.black12,
                  thumbColor: Colors.white,
                  overlayColor: Colors.black12,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                    elevation: 2,
                  ),
                ),
                child: Slider(
                  value: filters.radiusInKm,
                  min: 1.0,
                  max: 100.0,
                  divisions: 99,
                  label: '${filters.radiusInKm.round()} km',
                  onChanged: (value) =>
                      filtersNotifier.updateMaxDistance(value),
                ),
              ),
            ],
            _buildSectionTitle('Estado del Producto'),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: conditionMap.entries.map((entry) {
                final isSelected = filters.condition == entry.value;
                return ChoiceChip(
                  label: Text(entry.key),
                  selected: isSelected,
                  selectedColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black87 : Colors.black45,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? Colors.black87 : Colors.black12,
                      width: isSelected ? 1.4 : 0.8,
                    ),
                  ),
                  onSelected: (selected) {
                    filtersNotifier.updateCondition(
                      selected ? entry.value : null,
                    );
                  },
                );
              }).toList(),
            ),
            _buildSectionTitle('Rango de Equivalencia Estimada'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(filters.minPrice ?? 0.0).round()}€',
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                  Text(
                    '${(filters.maxPrice ?? 1000.0).round()}€',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.black87,
                inactiveTrackColor: Colors.black12,
                thumbColor: Colors.white,
                rangeThumbShape: const RoundRangeSliderThumbShape(
                  enabledThumbRadius: 10,
                  elevation: 2,
                ),
              ),
              child: RangeSlider(
                values: RangeValues(
                  filters.minPrice ?? 0.0,
                  filters.maxPrice ?? 1000.0,
                ),
                min: 0.0,
                max: 1000.0,
                divisions: 20,
                onChanged: (values) =>
                    filtersNotifier.updatePriceRange(values.start, values.end),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    alignment: Alignment.topCenter,
                    child: child,
                  ),
                );
              },
              child: filters.isPriceRangeInvalid
                  ? Padding(
                      key: const ValueKey('PriceRangeErrorAlert'),
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEAEA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFFC5C5),
                            width: 1.0,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFD32F2F),
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'El precio mínimo no puede superar al máximo.',
                                style: TextStyle(
                                  color: Color(0xFFC62828),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('EmptyErrorAlert')),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: filters.isPriceRangeInvalid
                  ? null
                  : () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.black12,
                disabledForegroundColor: Colors.black38,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Aplicar filtros',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
