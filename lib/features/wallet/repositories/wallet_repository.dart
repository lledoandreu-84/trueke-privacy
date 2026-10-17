import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallet_model.dart';

abstract class WalletRepository {
  Future<WalletModel> getWallet(String userId);
  Future<void> depositFunds({required String userId, required double amount});
}

class SupabaseWalletRepository implements WalletRepository {
  final SupabaseClient _client;
  static const _tableName = 'user_wallets';

  // Interceptor exclusivo para inyección y simulación atómica en suites de test
  final Future<Map<String, dynamic>> Function(String userId)?
  mockGetWalletInterceptor;

  SupabaseWalletRepository(this._client, {this.mockGetWalletInterceptor});

  @override
  Future<WalletModel> getWallet(String userId) async {
    if (mockGetWalletInterceptor != null) {
      final response = await mockGetWalletInterceptor!(userId);
      return WalletModel.fromJson(response);
    }

    final response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .single();
    return WalletModel.fromJson(response);
  }

  @override
  Future<void> depositFunds({
    required String userId,
    required double amount,
  }) async {
    if (mockGetWalletInterceptor != null) return;

    // RPC nativo en Postgres para realizar mutaciones de saldo con consistencia ACID
    await _client.rpc(
      'deposit_wallet_funds',
      params: {'target_user_id': userId, 'amount_to_add': amount},
    );
  }
}
