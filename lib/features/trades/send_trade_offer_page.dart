import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/features/products/providers/products_provider.dart';
import 'package:trueke/features/trades/providers/trade_offers_provider.dart';

class SendTradeOfferPage extends ConsumerStatefulWidget {
  const SendTradeOfferPage({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<SendTradeOfferPage> createState() => _SendTradeOfferPageState();
}

class _SendTradeOfferPageState extends ConsumerState<SendTradeOfferPage> {
  final _messageController = TextEditingController();
  Product? _selectedMyProduct;
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitOffer() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, introduce un mensaje para tu propuesta.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(tradeOffersProvider.notifier)
          .sendOffer(
            product: widget.product,
            message: _messageController.text.trim(),
            offeredProduct: _selectedMyProduct,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Propuesta de trueque enviada con éxito!'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al enviar la oferta: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Proponer Trueque',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Estás proposing un intercambio por:',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const Divider(height: 32),
                const Text(
                  '¿Qué artículo de tu propiedad ofreces a cambio?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                productsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) =>
                      Text('Error al cargar tus productos: $err'),
                  data: (products) {
                    final myId = AuthService.currentUserId;
                    final myProducts = products
                        .where((p) => p.ownerId == myId)
                        .toList();

                    if (myProducts.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No tienes artículos publicados para ofrecer. Puedes proponer un trueque abierto.',
                          ),
                        ),
                      );
                    }
                    return DropdownButtonFormField<Product>(
                      initialValue: _selectedMyProduct,
                      hint: const Text(
                        'Selecciona uno de tus artículos (Opcional)',
                      ),
                      isExpanded: true,
                      items: myProducts.map((prod) {
                        return DropdownMenuItem<Product>(
                          value: prod,
                          child: Text(prod.title),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedMyProduct = val);
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Escribe un mensaje explicando tu propuesta:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText:
                        'Ej: Hola, te cambio mi artículo por el tuyo y puedo aportar la diferencia si te interesa...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _submitOffer,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  icon: const Icon(Icons.send_rounded),
                  label: const Text(
                    'Enviar Propuesta Oficial',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
    );
  }
}
