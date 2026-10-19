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
    final theme = Theme.of(context);

    return escrowAsync.when(
      loading: () => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ),
      ),
      error: (error, _) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error en la pasarela de garantía: $error',
                style: TextStyle(
                  color: theme.colorScheme.error,
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
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, tx),
                Divider(
                  height: 24,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                _buildStatusTimeline(context, tx.status),
                Divider(
                  height: 24,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
                _buildTrackingDetails(context, tx),
                if (isSeller && tx.status == EscrowStatus.heldInEscrow) ...[
                  const SizedBox(height: 16),
                  _buildLogisticsForm(context, ref, tx.id),
                ],
                if ((isBuyer || isSeller) && canCancel) ...[
                  Divider(
                    height: 24,
                    thickness: 1,
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showCancelDialog(context, ref, tx.id),
                      icon: Icon(
                        Icons.cancel_outlined,
                        color: theme.colorScheme.error,
                        size: 16,
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: theme.colorScheme.error,
                      ),
                      label: Text(
                        'Cancelar Trueque y Reembolsar',
                        style: TextStyle(
                          color: theme.colorScheme.error,
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

  Widget _buildHeader(BuildContext context, EscrowTransaction tx) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Garantía de Depósito (Trueke Escrow)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ref: ${tx.id.length > 8 ? tx.id.substring(0, 8).toUpperCase() : tx.id.toUpperCase()}...',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Text(
            '${tx.amount.toStringAsFixed(2)} ${tx.currency.toUpperCase()}',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeline(BuildContext context, EscrowStatus currentStatus) {
    final theme = Theme.of(context);
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
        final color = isCompleted
            ? theme.colorScheme.primary
            : theme.colorScheme.outlineVariant;

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
                    color: isCompleted
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
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
                height: 2,
                color: index < currentIndex
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
          ],
        );
      }),
    );
  }

  Widget _buildTrackingDetails(BuildContext context, EscrowTransaction tx) {
    final theme = Theme.of(context);
    if (tx.status == EscrowStatus.pendingDeposit) {
      return Text(
        'Esperando depósito seguro del comprador...',
        style: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      );
    }
    if (tx.status == EscrowStatus.heldInEscrow) {
      return Text(
        'Fondos custodiados. Esperando envío del vendedor.',
        style: TextStyle(
          color: theme.colorScheme.onSurface,
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
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Seguimiento: ${tx.trackingNumber ?? "Pendiente"}',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
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
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Introducir Información de Envío',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: trackingController,
                  decoration: _getInputDecoration(context, 'Nº Seguimiento'),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: carrierController,
                  decoration: _getInputDecoration(context, 'Agencia (ej. Seur)'),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton(
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
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size.fromHeight(36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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

  InputDecoration _getInputDecoration(BuildContext context, String hint) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        fontSize: 12,
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, String escrowId) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Cancelar Operación',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas cancelar este trueque? Los fondos depositados serán reembolsados íntegramente de forma automatizada.',
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(escrowRepositoryProvider)
                  .cancelAndRefundEscrow(escrowId: escrowId);
              if (context.mounted) Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirmar Reembolso',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
