import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/providers/products_provider.dart';
import '../../../home/widgets/product_card.dart';

class MyPublishedProductsScreen extends ConsumerWidget {
  const MyPublishedProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myProductsAsync = ref.watch(myProductsProvider);
    final width = MediaQuery.of(context).size.width;

    final int crossAxisCount = width < 700 ? 2 : (width < 1000 ? 3 : 4);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Productos Publicados')),
      body: myProductsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Aún no has publicado ningún artículo.\n¡Sube tu primer producto para empezar a hacer truekes!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Error cargando tus productos: $error')),
      ),
    );
  }
}
