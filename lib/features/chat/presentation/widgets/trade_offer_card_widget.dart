import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/chat/presentation/managers/trade_offer_notifier.dart';

class TradeOfferCardWidget extends ConsumerWidget {
  final String offerId;
  final String productTitle;
  final String status;
  final double amount;

  const TradeOfferCardWidget({
    super.key,
    required this.offerId,
    required this.productTitle,
    required this.status,
    required this.amount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerState = ref.watch(tradeOfferNotifierProvider(offerId));
    final isLoading = offerState.isLoading;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Compensación: ${amount.toStringAsFixed(2)}€',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            if (status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => ref
                                .read(
                                  tradeOfferNotifierProvider(offerId).notifier,
                                )
                                .updateOfferStatus('rejected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(
                          color: theme.colorScheme.error.withAlpha(100),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Rechazar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: isLoading
                          ? null
                          : () => ref
                                .read(
                                  tradeOfferNotifierProvider(offerId).notifier,
                                )
                                .updateOfferStatus('accepted'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Aceptar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ],

            if (status == 'accepted') ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.pin_drop_rounded, size: 18),
                label: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Encuentro Completado (100m Sol)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                onPressed: isLoading
                    ? null
                    : () {
                        const double madridSolLat = 40.416775;
                        const double madridSolLon = -3.703790;
                        ref
                            .read(tradeOfferNotifierProvider(offerId).notifier)
                            .updateOfferStatus(
                              'completed',
                              userLat: madridSolLat,
                              userLon: madridSolLon,
                              targetLat: madridSolLat,
                              targetLon: madridSolLon,
                            );
                      },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            if (offerState is AsyncError) ...[
              const SizedBox(height: 12),
              Text(
                '${offerState.error}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
