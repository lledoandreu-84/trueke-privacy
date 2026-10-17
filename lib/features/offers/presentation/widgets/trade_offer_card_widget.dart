import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/offers/models/trade_offer.dart';
import 'package:trueke/features/offers/providers/trade_offer_provider.dart';

class TradeOfferCard extends ConsumerWidget {
  final TradeOffer offer;
  final String currentUserId;

  const TradeOfferCard({
    super.key,
    required this.offer,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSender = offer.senderId == currentUserId;
    final isPending = offer.status == TradeOfferStatus.pending;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isSender ? 'Propuesta Enviada' : 'Propuesta Recibida',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                _buildStatusChip(context, offer.status),
              ],
            ),
            Divider(
              height: 24,
              thickness: 0.5,
              color: theme.colorScheme.outlineVariant,
            ),
            Text(
              'Producto Ofrecido ID: ${offer.senderProductId}',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'A cambio de ID: ${offer.receiverProductId}',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (offer.additionalCash > 0) ...[
              const SizedBox(height: 10),
              Text(
                'Compensación Económica: +${offer.additionalCash.toStringAsFixed(2)}€',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: theme.colorScheme.primary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
            if (isPending && !isSender) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showConfirmationDialog(
                        context,
                        ref,
                        '¿Rechazar esta propuesta?',
                        TradeOfferStatus.declined,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(
                          color: theme.colorScheme.error.withValues(alpha: 0.5),
                        ),
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Rechazar',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _showConfirmationDialog(
                        context,
                        ref,
                        '¿Aceptar este intercambio directo?',
                        TradeOfferStatus.accepted,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Aceptar Trueke',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, TradeOfferStatus status) {
    final theme = Theme.of(context);
    String label;
    Color bgColor;
    Color fgColor;

    switch (status) {
      case TradeOfferStatus.pending:
        label = 'Pendiente';
        bgColor = theme.colorScheme.surfaceContainerHighest;
        fgColor = theme.colorScheme.onSurfaceVariant;
        break;
      case TradeOfferStatus.accepted:
        label = 'Aceptado';
        bgColor = theme.colorScheme.primaryContainer;
        fgColor = theme.colorScheme.onPrimaryContainer;
        break;
      case TradeOfferStatus.declined:
        label = 'Rechazado';
        bgColor = theme.colorScheme.errorContainer;
        fgColor = theme.colorScheme.onErrorContainer;
        break;
      case TradeOfferStatus.canceled:
        label = 'Cancelado';
        bgColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1);
        fgColor = theme.colorScheme.inverseSurface;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fgColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    String title,
    TradeOfferStatus targetStatus,
  ) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.4,
          ),
        ),
        content: Text(
          'Esta acción modificará el estado del trueque de forma irreversible.',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: () {
              ref
                  .read(userTradeOffersProvider.notifier)
                  .resolveOffer(offer.id, targetStatus);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: targetStatus == TradeOfferStatus.accepted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
            child: Text(
              targetStatus == TradeOfferStatus.accepted
                  ? 'Confirmar'
                  : 'Rechazar',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
