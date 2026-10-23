import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'domain/models/trade_offer.dart';
import 'providers/trade_offers_provider.dart';

class TradeOffersPage extends ConsumerWidget {
  const TradeOffersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final offersAsync = ref.watch(tradeOffersProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          
          scrolledUnderElevation: 0,
          title: Text(
            'Propuestas de Trueke',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: -0.4,
              color: theme.colorScheme.onSurface,
            ),
          ),
          iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            dividerColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            tabs: const [
              Tab(text: 'Recibidas'),
              Tab(text: 'Enviadas'),
            ],
          ),
        ),
        body: offersAsync.when(
          data: (offers) {
            final incoming = offers.where((o) => o.isIncoming).toList();
            final outgoing = offers.where((o) => !o.isIncoming).toList();

            return TabBarView(
              children: [
                _OffersList(offers: incoming, isIncomingTab: true),
                _OffersList(offers: outgoing, isIncomingTab: false),
              ],
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Error al cargar ofertas: $err',
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OffersList extends ConsumerWidget {
  final List<TradeOffer> offers;
  final bool isIncomingTab;

  const _OffersList({required this.offers, required this.isIncomingTab});

  Color _getStatusColor(ColorScheme colorScheme, TradeOfferStatus status) {
    switch (status) {
      case TradeOfferStatus.sent:
        return colorScheme.tertiary;
      case TradeOfferStatus.accepted:
        return colorScheme.primary;
      case TradeOfferStatus.rejected:
        return colorScheme.error;
    }
  }

  String _getStatusLabel(TradeOfferStatus status) {
    switch (status) {
      case TradeOfferStatus.sent:
        return 'Pendiente';
      case TradeOfferStatus.accepted:
        return 'Aceptado';
      case TradeOfferStatus.rejected:
        return 'Rechazado';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (offers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            isIncomingTab
                ? 'No has recibido ninguna propuesta.'
                : 'No has enviado ninguna propuesta.',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        final statusColor = _getStatusColor(theme.colorScheme, offer.status);

        return Card(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Producto: ${offer.productTitle}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusLabel(offer.status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (offer.offeredProductTitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'A cambio de: ${offer.offeredProductTitle}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Mensaje: ${offer.message}',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                if (isIncomingTab && offer.isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => ref
                            .read(tradeOffersProvider.notifier)
                            .respondToOffer(
                              offer: offer,
                              status: TradeOfferStatus.rejected,
                            ),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: const Text('Rechazar'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => ref
                            .read(tradeOffersProvider.notifier)
                            .respondToOffer(
                              offer: offer,
                              status: TradeOfferStatus.accepted,
                            ),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          
                        ),
                        child: const Text('Aceptar'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
