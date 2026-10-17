import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/transaction.dart';

class TransactionRepository {
  final SupabaseClient _supabase;

  TransactionRepository(this._supabase);

  Future<void> createTransaction(ProductTransaction transaction) async {
    await _supabase.from('transactions').insert(transaction.toJson());
  }

  Future<List<ProductTransaction>> getUserTransactions(String userId) async {
    final response = await _supabase
        .from('transactions')
        .select()
        .or('buyer_id.eq.$userId,seller_id.eq.$userId')
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((json) {
      return ProductTransaction.fromJson(json as Map<String, dynamic>);
    }).toList();
  }

  Future<void> updateTransactionStatus(
    String transactionId,
    String status,
  ) async {
    await _supabase
        .from('transactions')
        .update({'status': status})
        .eq('id', transactionId);
  }

  /// Cambia el estado de una transacción y sincroniza el producto en una única operación atómica via RPC
  Future<void> actualizarEstadoTransaccionAtomica({
    required String transactionId,
    required String productId,
    required String nuevoEstado,
  }) async {
    await _supabase.rpc(
      'finalizar_trueque_atomico',
      params: {
        'p_transaction_id': transactionId,
        'p_product_id': productId,
        'p_nuevo_estado': nuevoEstado,
      },
    );
  }
}
