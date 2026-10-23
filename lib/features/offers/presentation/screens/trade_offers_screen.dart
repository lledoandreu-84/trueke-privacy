import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/shared/widgets/custom_app_bar.dart';

class TradeOffersScreen extends ConsumerWidget {
  const TradeOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(titleText: 'Intercambios Directos'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swap_horiz_rounded, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No hay intercambios directos activos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Aquí aparecerán las propuestas de trueke que realices o recibas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
