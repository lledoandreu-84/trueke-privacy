import 'package:trueke/features/transactions/models/trade_transaction.dart';

abstract class TransactionsRepository {
  /// Obtiene el historial de propuestas enviadas o recibidas por un usuario específico.
  Future<List<TradeTransaction>> getUserTransactions(String userId);

  /// Crea una nueva propuesta de trueque en el sistema.
  Future<void> createTransaction(TradeTransaction transaction);

  /// Actualiza el estado de una propuesta (Aceptar, rechazar o completar).
  Future<void> updateTransactionStatus(String transactionId, String newStatus);
}
