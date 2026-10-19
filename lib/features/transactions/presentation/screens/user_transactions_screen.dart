import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/transactions/providers/transactions_provider.dart';
import 'package:trueke/features/transactions/models/trade_transaction.dart';

class UserTransactionsScreen extends ConsumerWidget {
  final String userId;

  const UserTransactionsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(userTransactionsProvider(userId));
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Historial de Transacciones',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
              color: theme.colorScheme.onSurface,
            ),
          ),
          iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 2.0,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant.withValues(
              alpha: 0.6,
            ),
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.normal,
            ),
            tabs: const [
              Tab(text: 'Enviados'),
              Tab(text: 'Recibidos'),
            ],
          ),
        ),
        body: transactionsAsync.when(
          data: (transactions) {
            final sent = transactions
                .where((t) => t.senderId == userId)
                .toList();
            final received = transactions
                .where((t) => t.receiverId == userId)
                .toList();

            return TabBarView(
              children: [
                _TransactionsList(
                  transactions: sent,
                  isSender: true,
                  userId: userId,
                ),
                _TransactionsList(
                  transactions: received,
                  isSender: false,
                  userId: userId,
                ),
              ],
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error al cargar transacciones: $err',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  final List<TradeTransaction> transactions;
  final bool isSender;
  final String userId;

  const _TransactionsList({
    required this.transactions,
    required this.isSender,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'No hay propuestas en esta categoría.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return _TransactionItemRow(tx: tx, isSender: isSender, userId: userId);
      },
    );
  }
}

class _TransactionItemRow extends ConsumerStatefulWidget {
  final TradeTransaction tx;
  final bool isSender;
  final String userId;

  const _TransactionItemRow({
    required this.tx,
    required this.isSender,
    required this.userId,
  });

  @override
  ConsumerState<_TransactionItemRow> createState() =>
      _TransactionItemRowState();
}

class _TransactionItemRowState extends ConsumerState<_TransactionItemRow> {
  bool _isMutating = false;

  Future<void> _handleStatusChange(String newStatus) async {
    if (_isMutating) return;
    setState(() => _isMutating = true);
    try {
      await ref
          .read(userTransactionsProvider(widget.userId).notifier)
          .changeStatus(widget.tx.id, newStatus);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget? trailingAction;

    if (_isMutating) {
      trailingAction = SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator.adaptive(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
      );
    } else if (widget.tx.isExpired) {
      trailingAction = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          'EXPIRADO (48H)',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    } else if (!widget.isSender && widget.tx.status == 'pending') {
      trailingAction = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: () => _handleStatusChange('accepted'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(64, 38),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Aceptar',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _handleStatusChange('rejected'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
              minimumSize: const Size(64, 38),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Rechazar',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    } else {
      final isAccepted = widget.tx.status == 'accepted';
      trailingAction = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isAccepted
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          widget.tx.status.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isAccepted
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final displayTitle =
        'Trueque #${widget.tx.id.substring(0, 5).toUpperCase()}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID Completo: ${widget.tx.id}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailingAction,
        ],
      ),
    );
  }
}
