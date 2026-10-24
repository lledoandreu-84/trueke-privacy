import 'package:trueke/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/features/products/providers/products_provider.dart';
import 'package:trueke/features/products/publish_product_page.dart';
import 'package:trueke/features/products/product_detail_page.dart';

class MyPublishedProductsScreen extends ConsumerWidget {
  const MyPublishedProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUserId = AuthService.currentUserId;

    if (currentUserId == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: const Center(child: Text('Usuario no autenticado')),
      );
    }

    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const CustomAppBar(titleText: 'Mis Productos Publicados'),
      body: productsAsync.when(
        data: (products) {
          final myProducts = products.where((p) {
            return p.ownerId == currentUserId ;
          }).toList();

          if (myProducts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Aún no has publicado ningún artículo en tu escaparate.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: myProducts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = myProducts[index];
              final hasImg =
                  product.images.isNotEmpty && product.images.first.isNotEmpty;
              final productImg = hasImg ? product.images.first : '';

              return Material(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => ProductDetailPage(product: product),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 52,
                            height: 52,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: productImg.isNotEmpty
                                ? Image.network(
                                    productImg,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(
                                      Icons.image_not_supported_rounded,
                                      size: 20,
                                    ),
                                  )
                                : const Icon(Icons.image_rounded, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.price != null
                                    ? '${product.price!.toStringAsFixed(0)}€'
                                    : 'Trueque Puro',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary, size: 20),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) => PublishProductPage(product: product),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error, size: 20),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Eliminar producto'),
                                    content: const Text('¿Estás seguro de que deseas eliminar este producto de tu escaparate?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await ref.read(productsProvider.notifier).deleteProduct(product);
                                  ref.invalidate(productsProvider);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error al cargar escaparate: $err',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}
