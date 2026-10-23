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
      case ProductSortOption.mostViewed:
        return 'most_viewed';
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
      case 'most_viewed':
        return ProductSortOption.mostViewed;
      default:
        return ProductSortOption.relevance;
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 18.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros Avanzados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.4,
                  ),
                ),
                TextButton(
                  onPressed: () => filtersNotifier.clearFilters(),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                  ),
                  child: const Text(
                    'Limpiar todo',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
              ],
            ),
            Divider(
              height: 12,
              thickness: 0.5,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            _buildSectionTitle(context, 'Ordenar por'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _mapSortOptionToString(filters.sortBy),
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  dropdownColor: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                  items: [
                    DropdownMenuItem(
                      value: 'recent',
                      child: Text('Más recientes', style: TextStyle(color: theme.colorScheme.onSurface)),
                    ),
                    DropdownMenuItem(
                      value: 'most_viewed',
                      child: Text('Más vistos (Popularidad)', style: TextStyle(color: theme.colorScheme.onSurface)),
                    ),
                    DropdownMenuItem(
                      value: 'price_asc',
                      child: Text('Precio: menor a mayor', style: TextStyle(color: theme.colorScheme.onSurface)),
                    ),
                    DropdownMenuItem(
                      value: 'price_desc',
                      child: Text('Precio: mayor a menor', style: TextStyle(color: theme.colorScheme.onSurface)),
                    ),
                    if (hasLocation)
                      DropdownMenuItem(
                        value: 'distance',
                        child: Text('Cercanía geográfica', style: TextStyle(color: theme.colorScheme.onSurface)),
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
                Text(
                  'Usar mi ubicación actual',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Switch.adaptive(
                  value: hasLocation,
                  activeThumbColor: theme.colorScheme.primary,
                  activeTrackColor: theme.colorScheme.primaryContainer,
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
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: theme.colorScheme.primary,
                  inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
                  thumbColor: theme.colorScheme.onPrimary,
                  overlayColor: theme.colorScheme.primary.withValues(alpha: 0.12),
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
            _buildSectionTitle(context, 'Estado del Producto'),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: conditionMap.entries.map((entry) {
                final isSelected = filters.condition == entry.value;
                return ChoiceChip(
                  label: Text(entry.key),
                  selected: isSelected,
                  selectedColor: theme.colorScheme.primaryContainer,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
            _buildSectionTitle(context, 'Rango de Equivalencia Estimada'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(filters.minPrice ?? 0.0).round()}€',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    '${(filters.maxPrice ?? 1000.0).round()}€',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: theme.colorScheme.primary,
                inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
                thumbColor: theme.colorScheme.onPrimary,
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
                          color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.error.withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: theme.colorScheme.error,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'El precio mínimo no puede superar al máximo.',
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
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
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: filters.isPriceRangeInvalid
                    ? null
                    : () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  
                ),
                child: const Text(
                  'Aplicar filtros',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
