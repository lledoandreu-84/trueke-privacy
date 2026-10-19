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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Explorar Entorno GPS',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: -0.4,
            color: theme.colorScheme.onSurface,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: paginatedAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error: $error',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
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
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outlineVariant,
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
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
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
