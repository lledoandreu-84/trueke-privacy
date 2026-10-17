import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../models/product.dart';
import '../../products/product_detail_page.dart';

class SearchMapView extends StatelessWidget {
  const SearchMapView({
    super.key,
    required this.products,
    this.centerLatitude,
    this.centerLongitude,
  });

  final List<Product> products;
  final double? centerLatitude;
  final double? centerLongitude;

  @override
  Widget build(BuildContext context) {
    final defaultCenter = LatLng(
      centerLatitude ?? 40.416775,
      centerLongitude ?? -3.703790,
    );

    final markers = products
        .where((p) => p.latitude != null && p.longitude != null)
        .map(
          (product) => Marker(
            point: LatLng(product.latitude!, product.longitude!),
            width: 45,
            height: 45,
            child: GestureDetector(
              onTap: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => ProductDetailPage(product: product),
                  ),
                );
              },
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ),
        )
        .toList();

    return FlutterMap(
      options: MapOptions(
        initialCenter: defaultCenter,
        initialZoom: markers.isNotEmpty ? 12 : 6,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.trueke.app',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
