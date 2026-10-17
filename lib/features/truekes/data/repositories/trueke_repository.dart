import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/core/supabase/supabase_client.dart';
import 'package:trueke/features/truekes/data/models/trueke_model.dart';
import 'package:trueke/features/truekes/data/models/dispute_model.dart';
import 'package:trueke/features/truekes/data/models/escrow_model.dart';
import 'package:trueke/features/truekes/data/models/payment_order_model.dart';
import 'package:trueke/features/truekes/data/datasources/local_trueke_data_source.dart';
import 'package:trueke/main.dart';

class TruekeRepository {
  final SupabaseClient _client;
  final LocalTruekeDataSource _localDataSource;
  final Future<List<Map<String, dynamic>>> Function()? mockFetchMock;

  TruekeRepository(this._client, this._localDataSource, {this.mockFetchMock});

  // Obtener transacciones con estrategia híbrida inmunizada
  Future<List<TruekeModel>> fetchMyTruekes(String userId) async {
    try {
      if (userId.isEmpty) return [];

      final List<dynamic> data;

      if (mockFetchMock != null) {
        data = await mockFetchMock!();
      } else {
        final response = await _client
            .from('truekes')
            .select()
            .or('sender_id.eq.$userId,receiver_id.eq.$userId')
            .order('updated_at', ascending: false)
            .timeout(const Duration(seconds: 15));
        data = response as List<dynamic>;
      }

      final truekes = data
          .map((json) => TruekeModel.fromJson(json as Map<String, dynamic>))
          .toList();

      await _localDataSource.cacheTruekes(truekes);
      return truekes;
    } on PostgrestException catch (postgrestError) {
      final cachedTruekes = await _localDataSource.getCachedTruekes();
      if (cachedTruekes.isNotEmpty) return cachedTruekes;
      throw Exception(
        'Fallo en Supabase (${postgrestError.code}): ${postgrestError.message}',
      );
    } catch (e) {
      final cachedTruekes = await _localDataSource.getCachedTruekes();
      if (cachedTruekes.isNotEmpty) return cachedTruekes;
      throw Exception('Sin conexión y sin datos en caché: $e');
    }
  }

  // Abrir una disputa formal sobre un trueke específico en Supabase
  Future<DisputeModel> openDispute({
    required String truekeId,
    required String raisedBy,
    required String reason,
  }) async {
    try {
      final response = await _client
          .from('disputes')
          .insert({
            'trueke_id': truekeId,
            'raised_by': raisedBy,
            'reason': reason,
            'status': 'opened',
          })
          .select()
          .single()
          .timeout(const Duration(seconds: 15));
      return DisputeModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al abrir la disputa en Supabase: $e');
    }
  }

  // Firma exacta acoplada con el consumo real de payment_provider.dart
  Future<PaymentOrderModel> createPaymentOrder({
    required String truekeId,
    required String userId,
    required double amount,
    required String externalIntentId,
  }) async {
    try {
      final response = await _client
          .from('payment_orders')
          .insert({
            'trueke_id': truekeId,
            'user_id': userId,
            'amount': amount,
            'currency': 'EUR',
            'external_intent_id': externalIntentId,
            'status': 'pending',
          })
          .select()
          .single()
          .timeout(const Duration(seconds: 15));
      return PaymentOrderModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear la orden de pago: $e');
    }
  }

  // Firma con parámetros posicionales consumida por el proveedor de pagos
  Future<void> updatePaymentOrderStatus(String orderId, dynamic status) async {
    try {
      final String rawStatus = status is Enum ? status.name : status.toString();
      await _client
          .from('payment_orders')
          .update({
            'status': rawStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId)
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw Exception('Error al actualizar el estado de la orden de pago: $e');
    }
  }
}

class EscrowRepository {
  final SupabaseClient _client;

  EscrowRepository(this._client);

  Future<EscrowModel?> fetchEscrowLedger(String truekeId) async {
    try {
      final response = await _client
          .from('trueke_escrow_ledger')
          .select()
          .eq('trueke_id', truekeId)
          .maybeSingle()
          .timeout(const Duration(seconds: 15));

      if (response == null) return null;
      return EscrowModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al auditar el libro de depósitos colaterales: $e');
    }
  }
}

// Proveedores de Riverpod desacoplados para la capa de datos
final truekeRepositoryProvider = Provider<TruekeRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final localDS = LocalTruekeDataSource(prefs);
  return TruekeRepository(client, localDS);
});

final myTruekesListProvider = FutureProvider.family<List<TruekeModel>, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(truekeRepositoryProvider);
  return repository.fetchMyTruekes(userId);
});

final escrowRepositoryProvider = Provider<EscrowRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return EscrowRepository(client);
});

final truekeEscrowProvider = FutureProvider.family<EscrowModel?, String>((
  ref,
  truekeId,
) async {
  final repository = ref.watch(escrowRepositoryProvider);
  return repository.fetchEscrowLedger(truekeId);
});
