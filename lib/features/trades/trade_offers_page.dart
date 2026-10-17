import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'domain/models/trade_offer.dart';
import 'providers/trade_offers_provider.dart';

class TradeOffersPage extends ConsumerWidget {
  const TradeOffersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(tradeOffersProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Propuestas de Trueke',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            tabs: [
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Error al cargar ofertas: $err')),
        ),
      ),
    );
  }
}

class _OffersList extends ConsumerWidget {
  final List<TradeOffer> offers;
  final bool isIncomingTab;

  const _OffersList({required this.offers, required this.isIncomingTab});

  Color _getStatusColor(TradeOfferStatus status) {
    switch (status) {
      case TradeOfferStatus.sent:
        return Colors.orange;
      case TradeOfferStatus.accepted:
        return Colors.green;
      case TradeOfferStatus.rejected:
        return Colors.red;
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
    if (offers.isEmpty) {
      return Center(
        child: Text(
          isIncomingTab
              ? 'No has recibido ninguna propuesta.'
              : 'No has enviado ninguna propuesta.',
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Producto: ${offer.productTitle}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        _getStatusLabel(offer.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: _getStatusColor(offer.status),
                    ),
                  ],
                ),
                if (offer.offeredProductTitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'A cambio de: ${offer.offeredProductTitle}',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Mensaje: ${offer.message}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                if (isIncomingTab && offer.isPending) ...[
                  const SizedBox(height: 12),
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
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Rechazar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(tradeOffersProvider.notifier)
                            .respondToOffer(
                              offer: offer,
                              status: TradeOfferStatus.accepted,
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
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
