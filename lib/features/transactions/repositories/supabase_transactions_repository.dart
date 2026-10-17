import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/transactions/models/trade_transaction.dart';
import 'package:trueke/features/transactions/repositories/transactions_repository.dart';

class SupabaseTransactionsRepository implements TransactionsRepository {
  final SupabaseClient _supabaseClient;

  const SupabaseTransactionsRepository(this._supabaseClient);

  // Envoltura defensiva con Backoff Exponencial para aislar fallos efímeros de red
  Future<T> _retryOnNetworkError<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(milliseconds: 500),
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        final isNetworkIssue =
            e is SocketException ||
            e is TimeoutException ||
            e.toString().contains('network') ||
            e.toString().contains('Connection failed');

        if (!isNetworkIssue || attempts >= maxRetries) {
          rethrow;
        }

        await Future.delayed(delay);
        delay *= 2; // Multiplicador exponencial de retardo
      }
    }
  }

  @override
  Future<List<TradeTransaction>> getUserTransactions(String userId) async {
    return _retryOnNetworkError(() async {
      final response = await _supabaseClient
          .from('transactions')
          .select()
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .order('created_at', ascending: false);

      final jsonList = List<Map<String, dynamic>>.from(response);
      return jsonList.map((json) {
        return TradeTransaction.fromJson(json);
      }).toList();
    });
  }

  @override
  Future<void> createTransaction(TradeTransaction transaction) async {
    await _retryOnNetworkError(() async {
      await _supabaseClient.from('transactions').insert(transaction.toJson());
    });
  }

  @override
  Future<void> updateTransactionStatus(
    String transactionId,
    String newStatus,
  ) async {
    await _retryOnNetworkError(() async {
      await _supabaseClient
          .from('transactions')
          .update({'status': newStatus})
          .eq('id', transactionId);
    });
  }
}
