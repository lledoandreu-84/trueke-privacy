import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/product.dart';
import '../../../../models/transaction.dart';
import '../../providers/transaction_providers.dart';

class CreateOfferDialog extends ConsumerStatefulWidget {
  final Product product;

  const CreateOfferDialog({super.key, required this.product});

  @override
  ConsumerState<CreateOfferDialog> createState() => _CreateOfferDialogState();
}

class _CreateOfferDialogState extends ConsumerState<CreateOfferDialog> {
  final _priceController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitOffer() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      return;
    }

    final proposedPrice = double.tryParse(
      _priceController.text.trim().replaceAll(',', '.'),
    );

    // Validación defensiva de seguridad: Si el trato requiere dinero, blindar el valor mayor a cero
    if ((widget.product.tradeType == TradeType.tradeAndMoney ||
            widget.product.tradeType == TradeType.sale) &&
        (proposedPrice == null || proposedPrice <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Introduce una compensación económica válida mayor que 0 €.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black87,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final transaction = ProductTransaction(
      id: '',
      productId: widget.product.id,
      productTitle: widget.product.title,
      sellerId: widget.product.ownerId,
      sellerName: widget.product.owner,
      buyerId: currentUser.id,
      buyerName: currentUser.email?.split('@').first ?? 'Comprador',
      price: proposedPrice,
      status: TransactionStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // Invocación al método original correcto que procesa ProductTransaction en tu notifier
      await ref
          .read(userTransactionsProvider.notifier)
          .createOffer(transaction);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar propuesta: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black87,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Proponer Trueke',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.black87,
          letterSpacing: -0.4,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¿Quieres proponer un intercambio por ${widget.product.title}?',
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                height: 1.4,
                letterSpacing: -0.1,
              ),
            ),
            if (widget.product.tradeType == TradeType.tradeAndMoney ||
                widget.product.tradeType == TradeType.sale) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                style: const TextStyle(color: Colors.black87, fontSize: 15),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'Compensación económica (€)',
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F7),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.black12,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black54,
                  minimumSize: const Size.fromHeight(42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton(
                onPressed: _isSubmitting ? null : _submitOffer,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.black38,
                  minimumSize: const Size.fromHeight(42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Enviar Oferta',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
