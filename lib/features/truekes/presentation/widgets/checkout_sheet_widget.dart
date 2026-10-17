import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/truekes/presentation/providers/payment_provider.dart';

class CheckoutSheetWidget extends ConsumerWidget {
  final String truekeId;
  final String userId;
  final double amount;

  const CheckoutSheetWidget({
    super.key,
    required this.truekeId,
    required this.userId,
    required this.amount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentState = ref.watch(paymentNotifierProvider);

    ref.listen<PaymentState>(paymentNotifierProvider, (previous, next) {
      if (next is PaymentSuccess) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Depósito colateral verificado. ¡Trueke asegurado!',
            ),
            backgroundColor: Colors.teal,
          ),
        );
      } else if (next is PaymentError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error en el pago: ${next.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Confirmación de Intercambio Seguro',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Para garantizar la seguridad del Trueke, se retendrá un depósito colateral en Escrow que será liberado al completarse el intercambio.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Depósito de Garantía'),
                      Text(
                        '${amount.toStringAsFixed(2)}€',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total a Retener',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${amount.toStringAsFixed(2)}€',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (paymentState is PaymentProcessing)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: () {
                ref
                    .read(paymentNotifierProvider.notifier)
                    .processTruekePayment(
                      truekeId: truekeId,
                      userId: userId,
                      amount: amount,
                    );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Confirmar y Asegurar Fondos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
