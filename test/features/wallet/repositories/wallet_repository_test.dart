import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/wallet/repositories/wallet_repository.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

void main() {
  group('SupabaseWalletRepository - Consistencia de Cuentas Virtuales', () {
    late FakeSupabaseClient fakeClient;

    setUp(() {
      fakeClient = FakeSupabaseClient();
    });

    test(
      'Debe calcular con precision de centimos los fondos totales combinando balance y escrow',
      () async {
        final repository = SupabaseWalletRepository(
          fakeClient,
          mockGetWalletInterceptor: (userId) async => {
            'id': 'w_001',
            'user_id': userId,
            'balance': 150.50,
            'escrow_balance': 49.50,
            'currency': 'EUR',
          },
        );

        final wallet = await repository.getWallet('usr_david_123');

        expect(wallet.balance, equals(150.50));
        expect(wallet.escrowBalance, equals(49.50));
        // 150.50 + 49.50 = 200.00 euros exactos
        expect(wallet.totalFunds, equals(200.00));
      },
    );
  });
}
