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

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Electrónica', 'icon': Icons.devices_rounded, 'color': Color(0xFFE3F2FD), 'iconColor': Color(0xFF1976D2)},
    {'name': 'Moda', 'icon': Icons.checkroom_rounded, 'color': Color(0xFFFCE4EC), 'iconColor': Color(0xFFC2185B)},
    {'name': 'Hogar', 'icon': Icons.chair_rounded, 'color': Color(0xFFFFF3E0), 'iconColor': Color(0xFFE65100)},
    {'name': 'Gaming', 'icon': Icons.sports_esports_rounded, 'color': Color(0xFFF3E5F5), 'iconColor': Color(0xFF7B1FA2)},
    {'name': 'Deporte', 'icon': Icons.sports_soccer_rounded, 'color': Color(0xFFE8F5E9), 'iconColor': Color(0xFF388E3C)},
    {'name': 'Otros', 'icon': Icons.category_rounded, 'color': Color(0xFFECEFF1), 'iconColor': Color(0xFF455A64)},
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(productFiltersProvider);
    final paginatedAsync = ref.watch(paginatedProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            const SliverToBoxAdapter(
              child: ColoredBox(color: AppColors.surface, child: HomeHeader()),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: PromoBanner(),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 22), // Espacio vertical generoso y visible
            ),
            const SliverToBoxAdapter(
              child: _SectionHeading(
                title: 'Categorías destacadas',
                subtitle: 'Explora por tipo de artículo',
                icon: Icons.grid_view_rounded,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.1,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final cat = _categories[index];
                  final name = cat['name'] as String;
                  final icon = cat['icon'] as IconData;
                  final bgColor = cat['color'] as Color;
                  final iconColor = cat['iconColor'] as Color;
                  final selected = filters.category == name;

                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(productFiltersProvider.notifier)
                          .toggleCategory(name);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? AppColors.primary : iconColor.withValues(alpha: 0.25),
                          width: selected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (selected ? AppColors.primary : iconColor).withValues(alpha: 0.08),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 18,
                            color: selected ? Colors.white : iconColor,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              name,
                              style: TextStyle(
                                color: selected ? Colors.white : AppColors.textPrimary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: _categories.length),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 22), // Espacio generoso antes de la sección de productos
            ),
            const SliverToBoxAdapter(
              child: _SectionHeading(
                title: 'Más buscados en tu zona',
                subtitle: 'Artículos relevantes cerca de tu GPS',
                icon: Icons.near_me_rounded,
              ),
            ),
            paginatedAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ),
              error: (error, stackTrace) => const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              ),
              data: (paginatedState) {
                final products = paginatedState.products;

                if (products.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No hay artículos disponibles en esta zona por el momento.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ),
                  );
                }

                final displayProducts = products.take(2).toList();

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = displayProducts[index];
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
                    }, childCount: displayProducts.length),
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
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.surfaceMint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 15),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
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
