import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../products/providers/product_filters_provider.dart';
import '../products/providers/paginated_products_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/product_card.dart';
import 'widgets/promo_banner.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent * 0.85) return;

    final paginatedState = ref.read(paginatedProductsProvider);
    paginatedState.whenData((state) {
      if (!state.isLoadingMore) {
        ref.read(paginatedProductsProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final paginatedAsync = ref.watch(paginatedProductsProvider);
    final filters = ref.watch(productFiltersProvider);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 700 ? 2 : (width < 1000 ? 3 : 4);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            const SliverToBoxAdapter(
              child: ColoredBox(color: AppColors.surface, child: HomeHeader()),
            ),
            const SliverToBoxAdapter(child: PromoBanner()),

            const SliverToBoxAdapter(
              child: _SectionHeading(
                title: 'Categorías destacadas',
                subtitle: 'Encuentra algo que encaje contigo',
                icon: Icons.grid_view_rounded,
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.4,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    const categoriesData = [
                      {"name": "Electrónica", "icon": Icons.devices_rounded, "color": Color(0xFF3B82F6)},
                      {"name": "Moda", "icon": Icons.checkroom_rounded, "color": Color(0xFFEC4899)},
                      {"name": "Hogar", "icon": Icons.chair_rounded, "color": Color(0xFFF59E0B)},
                      {"name": "Gaming", "icon": Icons.sports_esports_rounded, "color": Color(0xFF8B5CF6)},
                      {"name": "Deporte", "icon": Icons.sports_soccer_rounded, "color": Color(0xFF10B981)},
                      {"name": "Otros", "icon": Icons.widgets_rounded, "color": Color(0xFF6B7280)},
                    ];
                    final cat = categoriesData[index];
                    final String name = cat["name"] as String;
                    final IconData icon = cat["icon"] as IconData;
                    final Color catColor = cat["color"] as Color;
                    final bool isSelected = filters.category == name;

                    return InkWell(
                      onTap: () {
                        ref.read(productFiltersProvider.notifier).toggleCategory(name);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? catColor : catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? catColor : catColor.withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: catColor.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icon,
                              size: 22,
                              color: isSelected ? Colors.white : catColor,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: 6,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: _SectionHeading(
                title: filters.hasActiveFilters
                    ? 'Resultados encontrados'
                    : 'Descubre artículos',
                subtitle: filters.hasActiveFilters
                    ? 'Artículos según tus filtros'
                    : 'Segunda vida para cosas extraordinarias',
                icon: filters.hasActiveFilters
                    ? Icons.filter_alt_rounded
                    : Icons.auto_awesome_rounded,
                topPadding: 28,
              ),
            ),

            paginatedAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 56),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
              error: (error, stackTrace) => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 28, 24, 48),
                  child: _CatalogMessage(
                    icon: Icons.cloud_off_rounded,
                    title: 'No hemos podido cargar los artículos',
                    message: 'Comprueba tu conexión e inténtalo de nuevo.',
                    iconColor: AppColors.coral,
                  ),
                ),
              ),
              data: (paginatedState) {
                final products = paginatedState.products;

                if (products.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 28, 24, 48),
                      child: _CatalogMessage(
                        icon: Icons.search_off_rounded,
                        title: 'Todavía no hay resultados',
                        message:
                            'Prueba otra categoría para descubrir más artículos.',
                        iconColor: AppColors.petrolBlue,
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.74,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
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
                    }, childCount: products.length),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.topPadding = 26,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceMint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogMessage extends StatelessWidget {
  const _CatalogMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
