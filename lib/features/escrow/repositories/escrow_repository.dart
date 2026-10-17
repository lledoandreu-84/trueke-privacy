import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../models/escrow_transaction.dart';

abstract class EscrowRepository {
  Future<EscrowTransaction> getEscrowByTradeOfferId(String tradeOfferId);
  Stream<EscrowTransaction> streamEscrowByTradeOfferId(String tradeOfferId);
  Future<EscrowTransaction> createEscrow({
    required String tradeOfferId,
    required double amount,
    required String currency,
  });
  Future<EscrowTransaction> updateTrackingInfo({
    required String escrowId,
    required String trackingNumber,
    required String carrier,
  });
  Future<EscrowTransaction> cancelAndRefundEscrow({required String escrowId});
  Future<EscrowTransaction> releaseEscrowFunds({required String escrowId});
}

class SupabaseEscrowRepository implements EscrowRepository {
  final SupabaseClient _supabaseClient;

  SupabaseEscrowRepository(this._supabaseClient);

  @override
  Future<EscrowTransaction> getEscrowByTradeOfferId(String tradeOfferId) async {
    final response = await _supabaseClient
        .from('escrow_transactions')
        .select()
        .eq('trade_offer_id', tradeOfferId)
        .single();
    return EscrowTransaction.fromJson(response);
  }

  @override
  Stream<EscrowTransaction> streamEscrowByTradeOfferId(String tradeOfferId) {
    return _supabaseClient
        .from('escrow_transactions')
        .stream(primaryKey: ['id'])
        .eq('trade_offer_id', tradeOfferId)
        .map((maps) {
          if (maps.isEmpty) {
            throw Exception(
              'No se encontró ninguna transacción de escrow activa.',
            );
          }
          return EscrowTransaction.fromJson(maps.first);
        });
  }

  @override
  Future<EscrowTransaction> createEscrow({
    required String tradeOfferId,
    required double amount,
    required String currency,
  }) async {
    final response = await _supabaseClient
        .from('escrow_transactions')
        .insert({
          'trade_offer_id': tradeOfferId,
          'amount': amount,
          'currency': currency,
          'status': 'pending_deposit',
        })
        .select()
        .single();
    return EscrowTransaction.fromJson(response);
  }

  @override
  Future<EscrowTransaction> updateTrackingInfo({
    required String escrowId,
    required String trackingNumber,
    required String carrier,
  }) async {
    final response = await _supabaseClient
        .from('escrow_transactions')
        .update({
          'tracking_number': trackingNumber,
          'carrier': carrier,
          'status': 'shipped',
        })
        .eq('id', escrowId)
        .select()
        .single();
    return EscrowTransaction.fromJson(response);
  }

  @override
  Future<EscrowTransaction> cancelAndRefundEscrow({
    required String escrowId,
  }) async {
    final response = await _supabaseClient
        .from('escrow_transactions')
        .update({'status': 'refunded'})
        .eq('id', escrowId)
        .select()
        .single();
    return EscrowTransaction.fromJson(response);
  }

  @override
  Future<EscrowTransaction> releaseEscrowFunds({
    required String escrowId,
  }) async {
    final response = await _supabaseClient
        .from('escrow_transactions')
        .update({'status': 'completed'})
        .eq('id', escrowId)
        .select()
        .single();
    return EscrowTransaction.fromJson(response);
  }
}

final escrowRepositoryProvider = Provider<EscrowRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseEscrowRepository(supabaseClient);
});

final escrowTransactionStreamProvider = StreamProvider.autoDispose
    .family<EscrowTransaction, String>((ref, tradeOfferId) {
      final repository = ref.watch(escrowRepositoryProvider);
      return repository.streamEscrowByTradeOfferId(tradeOfferId);
    });
