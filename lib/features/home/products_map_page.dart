import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../app/routes/app_routes.dart';
import '../products/providers/paginated_products_provider.dart';
import 'widgets/product_card.dart';

class ProductsMapPage extends ConsumerStatefulWidget {
  const ProductsMapPage({super.key});

  @override
  ConsumerState<ProductsMapPage> createState() => _ProductsMapPageState();
}

class _ProductsMapPageState extends ConsumerState<ProductsMapPage> {
  static const LatLng _madridEspana = LatLng(40.416775, -3.703790);

  @override
  Widget build(BuildContext context) {
    final paginatedAsync = ref.watch(paginatedProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFECFDF5),
      appBar: AppBar(title: const Text('EXPLORAR ENTORNO GPS')),
      body: paginatedAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (state) {
          final productsWithGeo = state.products
              .where((p) => p.latitude != null && p.longitude != null)
              .toList();

          final Set<Marker> markers = productsWithGeo.map((product) {
            return Marker(
              markerId: MarkerId(product.id),
              position: LatLng(product.latitude!, product.longitude!),
              infoWindow: InfoWindow(
                title: product.title,
                snippet: product.price != null
                    ? '${product.price}€'
                    : 'Trueque Puro',
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(ctx).pop();
                            Navigator.pushNamed(
                              context,
                              AppRoutes.product,
                              arguments: product,
                            );
                          },
                          child: SizedBox(
                            height: 140,
                            child: ProductCard(product: product),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toSet();

          return Stack(
            children: [
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: _madridEspana,
                    zoom: 11.5,
                  ),
                  markers: markers,
                  myLocationEnabled: true, // Punto azul activo
                  myLocationButtonEnabled:
                      true, // Botón de Mi Ubicación Forzado
                  zoomControlsEnabled:
                      true, // Habilitar zoom nativo anti-bloqueos
                  mapToolbarEnabled: true,
                  onMapCreated: (GoogleMapController controller) {},
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
