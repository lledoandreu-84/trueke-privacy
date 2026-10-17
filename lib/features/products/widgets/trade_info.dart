import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/product.dart';

class TradeInfo extends StatelessWidget {
  final Product product;

  const TradeInfo({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección estilizado con tipografía premium marcada
        const Text(
          'Lo que busca a cambio',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        // Texto del trueque totalmente libre de tarjetas o contenedores opacos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Text(
            product.wanted,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
