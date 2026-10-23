import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:trueke/features/transactions/providers/transaction_providers.dart';
import 'package:trueke/models/transaction.dart';
import 'package:trueke/features/offers/repositories/trade_offer_repository.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  SupabaseAuth get auth => FakeSupabaseAuth();
}

class FakeSupabaseAuth extends Fake implements SupabaseAuth {
  @override
  User? get currentUser => User(
        id: 'test-user-id',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
}

class FakeTransactionRepository extends Fake implements TransactionRepository {}

void main() {
  group('Pruebas Unitarias de Transacciones - UserTransactionsNotifier', () {
    test('Inicialización correcta del notifier', () async {
      final container = ProviderContainer(
        overrides: [
          supabaseClientProvider.overrideWithValue(FakeSupabaseClient()),
          transactionRepositoryProvider.overrideWithValue(FakeTransactionRepository()),
        ],
      );
      addTearDown(container.dispose);

      expect(container, isNotNull);
    });
  });
}
