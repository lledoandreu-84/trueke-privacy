import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/search_provider.dart';

class SearchFiltersWidget extends ConsumerWidget {
  const SearchFiltersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(searchFiltersProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros de Búsqueda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.4,
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(searchFiltersProvider.notifier).resetFilters();
                },
                child: Text(
                  'Limpiar',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Divider(
            height: 24,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          Text(
            'Ordenar por',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Más recientes'),
                selected: filters.sortBy == SearchSortBy.recent,
                onSelected: (selected) {
                  ref
                      .read(searchFiltersProvider.notifier)
                      .setSortBy(SearchSortBy.recent);
                },
                selectedColor: theme.colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: filters.sortBy == SearchSortBy.recent
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              ChoiceChip(
                label: const Text('Precio: más bajo'),
                selected: filters.sortBy == SearchSortBy.priceAsc,
                onSelected: (selected) {
                  ref
                      .read(searchFiltersProvider.notifier)
                      .setSortBy(SearchSortBy.priceAsc);
                },
                selectedColor: theme.colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: filters.sortBy == SearchSortBy.priceAsc
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              ChoiceChip(
                label: const Text('Precio: más alto'),
                selected: filters.sortBy == SearchSortBy.priceDesc,
                onSelected: (selected) {
                  ref
                      .read(searchFiltersProvider.notifier)
                      .setSortBy(SearchSortBy.priceDesc);
                },
                selectedColor: theme.colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: filters.sortBy == SearchSortBy.priceDesc
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Aplicar Filtros',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
