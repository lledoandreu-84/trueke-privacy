import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../data/services/postgis_location_service.dart';

class MapEncounterScreen extends ConsumerStatefulWidget {
  const MapEncounterScreen({
    super.key,
    required this.targetLat,
    required this.targetLon,
  });
  final double targetLat;
  final double targetLon;

  @override
  ConsumerState<MapEncounterScreen> createState() => _MapEncounterScreenState();
}

class _MapEncounterScreenState extends ConsumerState<MapEncounterScreen> {
  late final PostgisLocationService _locationService;
  double _currentDistance = double.infinity;
  bool _isCalculating = false;

  final double _myLat = 40.416775;
  final double _myLon = -3.703790;

  @override
  void initState() {
    super.initState();
    _locationService = PostgisLocationService(
      supabase: ref.read(supabaseClientProvider),
    );
    _calculateMeetingDistance();
  }

  Future<void> _calculateMeetingDistance() async {
    if (_isCalculating) return;
    setState(() => _isCalculating = true);
    try {
      final distance = await _locationService.checkDistanceBetweenPoints(
        startLat: _myLat,
        startLon: _myLon,
        endLat: widget.targetLat,
        endLon: widget.targetLon,
      );
      if (mounted) {
        setState(() {
          _currentDistance = distance;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _currentDistance = double.infinity;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isCalculating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWithinRange = _currentDistance <= 100.0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        
        scrolledUnderElevation: 0,
        title: Text(
          'Punto de Encuentro',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: -0.4,
            color: theme.colorScheme.onSurface,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        isWithinRange
                            ? Icons.gpp_good_rounded
                            : Icons.fmd_bad_rounded,
                        size: 64,
                        color: isWithinRange
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentDistance == double.infinity
                            ? 'Calculando distancia...'
                            : 'Distancia actual: ${_currentDistance.toStringAsFixed(1)} metros',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isWithinRange
                            ? 'Estáis a menos de 100 metros. Podéis proceder al intercambio seguro en el nodo físico.'
                            : 'Operación bloqueada. Debéis estar a menos de 100 metros para liberar o reclamar el escrow.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: _isCalculating
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Text(
                        'Verificar Cercanía Realtime',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                onPressed: _isCalculating ? null : _calculateMeetingDistance,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
