import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/providers/products_provider.dart';
import '../../../home/widgets/product_card.dart';
import '../../../../core/theme/app_colors.dart';

class MyPublishedProductsScreen extends ConsumerWidget {
  const MyPublishedProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myProductsAsync = ref.watch(myProductsProvider);
    final width = MediaQuery.of(context).size.width;

    final int crossAxisCount = width < 700 ? 2 : (width < 1000 ? 3 : 4);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mis Productos Publicados',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: myProductsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aún no has publicado ningún artículo.\n¡Sube tu primer producto para empezar a hacer truekes!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error cargando tus productos: $error',
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
