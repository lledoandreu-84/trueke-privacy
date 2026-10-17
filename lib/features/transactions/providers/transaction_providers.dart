import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/transaction.dart';
import '../data/transaction_repository.dart';

// Proveedor del cliente de Supabase para permitir desacoplamiento en tests
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(supabaseClientProvider));
});

final userTransactionsProvider =
    AsyncNotifierProvider<UserTransactionsNotifier, List<ProductTransaction>>(
      () {
        return UserTransactionsNotifier();
      },
    );

class UserTransactionsNotifier extends AsyncNotifier<List<ProductTransaction>> {
  @override
  Future<List<ProductTransaction>> build() async {
    final client = ref.watch(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) return [];
    return ref.read(transactionRepositoryProvider).getUserTransactions(user.id);
  }

  Future<void> createOffer(ProductTransaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(transactionRepositoryProvider)
          .createTransaction(transaction);
      final client = ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;
      return ref
          .read(transactionRepositoryProvider)
          .getUserTransactions(user?.id ?? '');
    });
  }

  Future<void> changeStatus(String transactionId, String newStatus) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(transactionRepositoryProvider)
          .updateTransactionStatus(transactionId, newStatus);
      final client = ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;
      return ref
          .read(transactionRepositoryProvider)
          .getUserTransactions(user?.id ?? '');
    });
  }

  /// Procesa el cambio de estado de forma atómica actualizando el producto en base de datos
  /// e invalidando las transacciones locales del usuario para reflejar el cambio.
  Future<void> procesarCambioEstadoTrueque({
    required String transactionId,
    required String productId,
    required TransactionStatus nuevoEstado,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 1. Ejecutar la mutación atómica en el repositorio via RPC
      await ref
          .read(transactionRepositoryProvider)
          .actualizarEstadoTransaccionAtomica(
            transactionId: transactionId,
            productId: productId,
            nuevoEstado: nuevoEstado.name,
          );

      // 2. Retornar el estado actualizado de transacciones del usuario
      final client = ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;
      return ref
          .read(transactionRepositoryProvider)
          .getUserTransactions(user?.id ?? '');
    });
  }
}
