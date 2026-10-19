import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../models/product.dart';
import '../../products/product_detail_page.dart';
import '../../../core/providers/location_providers.dart';

class SearchMapView extends ConsumerStatefulWidget {
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
  ConsumerState<SearchMapView> createState() => _SearchMapViewState();
}

class _SearchMapViewState extends ConsumerState<SearchMapView> {
  late final MapController _mapController;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _goToCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    try {
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentLocation();
      if (position != null) {
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          14.0,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo obtener la ubicación actual.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo obtener la ubicación actual.')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultCenter = LatLng(
      widget.centerLatitude ?? 40.416775,
      widget.centerLongitude ?? -3.703790,
    );

    final markers = widget.products
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
              child: Icon(
                Icons.location_on_rounded,
                color: theme.colorScheme.primary,
                size: 40,
              ),
            ),
          ),
        )
        .toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
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
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.primary,
            elevation: 4,
            onPressed: _isLoadingLocation ? null : _goToCurrentLocation,
            child: _isLoadingLocation
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : const Icon(Icons.my_location_rounded),
          ),
        ),
      ],
    );
  }
}
