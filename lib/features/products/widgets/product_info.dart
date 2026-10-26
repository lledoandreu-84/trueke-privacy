import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/product.dart';

class ProductInfo extends StatelessWidget {
  final Product product;

  const ProductInfo({super.key, required this.product});

  String get tradeLabel {
    switch (product.tradeType) {
      case TradeType.trade:
        return "Trueque";
      case TradeType.sale:
        return "Venta";
      case TradeType.tradeAndMoney:
        return "Trueque + €";
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPrice = product.price != null && product.price! > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta de tipo de trato minimalista con borde fino gris claro
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceMint,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: Text(
            tradeLabel.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Título con tracking tipográfico estilo Apple
        Text(
          product.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 12),
        // Precio o Trueque destacado en un contenedor llamativo y enorme
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: hasPrice ? AppColors.primary.withOpacity(0.08) : AppColors.surfaceMint,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasPrice ? AppColors.primary.withOpacity(0.3) : AppColors.primary.withOpacity(0.2),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasPrice ? Icons.sell_rounded : Icons.swap_horiz_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                hasPrice
                    ? "${product.price!.toStringAsFixed(0)} €"
                    : "Trueque Directo",
                style: const TextStyle(
                  fontSize: 28,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Fila de metadato: Estado de conservación premium monocromático
        Row(
          children: [
            const SizedBox(
              width: 85,
              child: Text(
                "Estado",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            Text(
              product.condition,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Fila de metadato: Ubicación limpia
        Row(
          children: [
            const SizedBox(
              width: 85,
              child: Text(
                "Ubicación",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            Expanded(
              child: Text(
                product.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
