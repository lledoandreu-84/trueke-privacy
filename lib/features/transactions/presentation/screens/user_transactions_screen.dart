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
            ),
          ),
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 2.0,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant.withAlpha(
              150,
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
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
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
              color: theme.colorScheme.onSurfaceVariant.withAlpha(180),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
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
      trailingAction = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
      );
    } else if (widget.tx.isExpired) {
      trailingAction = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Text(
          'EXPIRADO (48H)',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant.withAlpha(180),
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
              minimumSize: const Size(64, 34),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Aceptar',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 6),
          OutlinedButton(
            onPressed: () => _handleStatusChange('rejected'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error.withAlpha(100)),
              minimumSize: const Size(64, 34),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
      trailingAction = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: widget.tx.status == 'accepted'
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          widget.tx.status.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: widget.tx.status == 'accepted'
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final displayTitle =
        'Trueque #${widget.tx.id.substring(0, 5).toUpperCase()}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.5),
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
