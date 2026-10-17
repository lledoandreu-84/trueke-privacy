import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'models/product.dart';
import 'features/products/product_detail_page.dart';
import 'features/products/providers/product_filters_provider.dart';

class ProductMapView extends ConsumerWidget {
  final List<Product> products;

  const ProductMapView({super.key, required this.products});

  LatLng _getProductCoordinates(Product product) {
    if (product.latitude != null && product.longitude != null) {
      return LatLng(product.latitude!, product.longitude!);
    }
    final random = Random(product.id.hashCode);
    final offsetLat = (random.nextDouble() - 0.5) * 0.15;
    final offsetLng = (random.nextDouble() - 0.5) * 0.15;
    return LatLng(40.416775 + offsetLat, -3.703790 + offsetLng);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(productFiltersProvider);

    // Si el usuario tiene un filtro geográfico activo, centramos en su búsqueda; si no, fallback en Madrid
    final initialCenter =
        (filters.userLatitude != null && filters.userLongitude != null)
        ? LatLng(filters.userLatitude!, filters.userLongitude!)
        : const LatLng(40.416775, -3.703790);

    final markers = products.map((product) {
      final coordinates = _getProductCoordinates(product);

      return Marker(
        point: coordinates,
        width: 45,
        height: 45,
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (product.imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) =>
                                  const Icon(Icons.broken_image, size: 60),
                            ),
                          )
                        else
                          const Icon(Icons.image, size: 60),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.swap_horizontal_circle),
                        label: const Text('Proponer Trueque'),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  ProductDetailPage(product: product),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: const Icon(
            Icons.location_on,
            color: Colors.redAccent,
            size: 40,
          ),
        ),
      );
    }).toList();

    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: markers.isNotEmpty ? 11.0 : 6.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://openstreetmap.org{z}/{x}/{y}.png',
          userAgentPackageName: 'com.davidlledo.trueke',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
