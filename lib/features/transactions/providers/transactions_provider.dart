import 'package:trueke/features/chat/providers/chat_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/search/providers/search_repository_provider.dart';
import 'package:trueke/features/transactions/models/trade_transaction.dart';
import 'package:trueke/features/transactions/repositories/transactions_repository.dart';
import 'package:trueke/features/transactions/repositories/supabase_transactions_repository.dart';

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseTransactionsRepository(client);
});

class UserTransactionsNotifier extends AsyncNotifier<List<TradeTransaction>> {
  final String userId;

  UserTransactionsNotifier(this.userId);

  @override
  Future<List<TradeTransaction>> build() async {
    final repository = ref.watch(transactionsRepositoryProvider);
    return repository.getUserTransactions(userId);
  }

  Future<void> changeStatus(String transactionId, String newStatus) async {
    final currentTransactions = state.value ?? [];

    // Localizar la transacción real en el árbol de estado actual
    final transactionIndex = currentTransactions.indexWhere(
      (t) => t.id == transactionId,
    );
    if (transactionIndex == -1) {
      return;
    }

    final transaction = currentTransactions[transactionIndex];

    // Control perimetral estricto: Bloquear cualquier mutación si el plazo de 48 horas ha expirado
    if (transaction.isExpired) {
      throw Exception(
        'Esta propuesta de trueque ha caducado tras superar el límite de 48 horas.',
      );
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionsRepositoryProvider);
      await repository.updateTransactionStatus(transactionId, newStatus);

      if (transaction.id.isNotEmpty) {
        try {
          final chatRepo = ref.read(chatRepositoryProvider);
          final chatRoom = await chatRepo.getOrCreateChatRoom(
            productId: transaction.requestedProductId,
            buyerId: transaction.senderId,
            sellerId: transaction.receiverId,
          );

          await chatRepo.sendMessage(
            roomId: chatRoom.id,
            senderId: transaction.senderId,
            message:
                'El estado del trueque ha cambiado a: ${newStatus.toUpperCase()}',
            isSystem: true,
          );
        } catch (_) {
          // Fallback silencioso para aislamiento de infraestructura
        }
      }

      return repository.getUserTransactions(userId);
    });
  }

  Future<void> proposeTrade(TradeTransaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionsRepositoryProvider);
      await repository.createTransaction(transaction);

      try {
        final chatRepo = ref.read(chatRepositoryProvider);
        final chatRoom = await chatRepo.getOrCreateChatRoom(
          productId: transaction.requestedProductId,
          buyerId: transaction.senderId,
          sellerId: transaction.receiverId,
        );

        await chatRepo.sendMessage(
          roomId: chatRoom.id,
          senderId: transaction.senderId,
          message: 'Se ha enviado una nueva propuesta de trueque.',
          isSystem: true,
        );
      } catch (_) {
        // Fallback silencioso de mensajería reactiva
      }

      return repository.getUserTransactions(userId);
    });
  }
}

final userTransactionsProvider = AsyncNotifierProvider.autoDispose
    .family<UserTransactionsNotifier, List<TradeTransaction>, String>(
      UserTransactionsNotifier.new,
    );
