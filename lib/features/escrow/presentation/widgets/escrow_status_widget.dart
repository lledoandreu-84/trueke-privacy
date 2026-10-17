import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/escrow_transaction.dart';
import '../../repositories/escrow_repository.dart';
import '../../../../features/auth/auth_service.dart';

class EscrowStatusWidget extends ConsumerWidget {
  final String tradeOfferId;

  const EscrowStatusWidget({super.key, required this.tradeOfferId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escrowAsync = ref.watch(
      escrowTransactionStreamProvider(tradeOfferId),
    );
    final currentUserId = AuthService.currentUserId;

    return escrowAsync.when(
      loading: () => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
          ),
        ),
      ),
      error: (error, _) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x33FF5252), width: 0.8),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error en la pasarela de garantía: $error',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      data: (tx) {
        final isSeller = currentUserId == tx.sellerId;
        final isBuyer = currentUserId == tx.buyerId;
        final canCancel =
            (tx.status == EscrowStatus.pendingDeposit ||
            tx.status == EscrowStatus.heldInEscrow);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12, width: 0.8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(tx),
                const Divider(
                  height: 24,
                  thickness: 0.5,
                  color: Colors.black12,
                ),
                _buildStatusTimeline(tx.status),
                const Divider(
                  height: 24,
                  thickness: 0.5,
                  color: Colors.black12,
                ),
                _buildTrackingDetails(tx),
                if (isSeller && tx.status == EscrowStatus.heldInEscrow) ...[
                  const SizedBox(height: 16),
                  _buildLogisticsForm(context, ref, tx.id),
                ],
                if ((isBuyer || isSeller) && canCancel) ...[
                  const Divider(
                    height: 24,
                    thickness: 0.5,
                    color: Colors.black12,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showCancelDialog(context, ref, tx.id),
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      label: const Text(
                        'Cancelar Trueque y Reembolsar',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(EscrowTransaction tx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Garantía de Depósito (Trueke Escrow)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ref: ${tx.id.length > 8 ? tx.id.substring(0, 8).toUpperCase() : tx.id.toUpperCase()}...',
              style: const TextStyle(color: Colors.black38, fontSize: 12),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12, width: 0.5),
          ),
          child: Text(
            '${tx.amount.toStringAsFixed(2)} ${tx.currency.toUpperCase()}',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeline(EscrowStatus currentStatus) {
    final stages = [
      {'status': EscrowStatus.pendingDeposit, 'label': 'Depósito'},
      {'status': EscrowStatus.heldInEscrow, 'label': 'Custodia'},
      {'status': EscrowStatus.shipped, 'label': 'Enviado'},
      {'status': EscrowStatus.released, 'label': 'Liberado'},
    ];

    int currentIndex = stages.indexWhere((s) => s['status'] == currentStatus);
    if (currentStatus == EscrowStatus.released ||
        currentStatus == EscrowStatus.delivered) {
      currentIndex = 3;
    }
    if (currentStatus == EscrowStatus.refunded) {
      currentIndex = 0;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(stages.length, (index) {
        final isCompleted = index <= currentIndex;
        final color = isCompleted ? Colors.black87 : Colors.black12;

        return Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: color,
                  size: 16,
                ),
                const SizedBox(height: 4),
                Text(
                  stages[index]['label'] as String,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
            if (index < stages.length - 1)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 20,
                height: 1,
                color: index < currentIndex ? Colors.black87 : Colors.black12,
              ),
          ],
        );
      }),
    );
  }

  Widget _buildTrackingDetails(EscrowTransaction tx) {
    if (tx.status == EscrowStatus.pendingDeposit) {
      return const Text(
        'Esperando depósito seguro del comprador...',
        style: TextStyle(color: Colors.black45, fontSize: 12),
      );
    }
    if (tx.status == EscrowStatus.heldInEscrow) {
      return const Text(
        'Fondos custodiados. Esperando envío del vendedor.',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logística: ${tx.carrier ?? "Correos"}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Seguimiento: ${tx.trackingNumber ?? "Pendiente"}',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildLogisticsForm(
    BuildContext context,
    WidgetRef ref,
    String escrowId,
  ) {
    final formKey = GlobalKey<FormState>();
    final trackingController = TextEditingController();
    final carrierController = TextEditingController();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Introducir Información de Envío',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: trackingController,
                  decoration: _getInputDecoration('Nº Seguimiento'),
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: carrierController,
                  decoration: _getInputDecoration('Agencia (ej. Seur)'),
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await ref
                    .read(escrowRepositoryProvider)
                    .updateTrackingInfo(
                      escrowId: escrowId,
                      trackingNumber: trackingController.text.trim(),
                      carrier: carrierController.text.trim(),
                    );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Confirmar Envío y Notificar',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 12),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, String escrowId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Cancelar Operación',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          '¿Estás seguro de que deseas cancelar este trueque? Los fondos depositados serán reembolsados íntegramente de forma automatizada.',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Volver',
              style: TextStyle(color: Colors.black45),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(escrowRepositoryProvider)
                  .cancelAndRefundEscrow(escrowId: escrowId);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text(
              'Confirmar Reembolso',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
