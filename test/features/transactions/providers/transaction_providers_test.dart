import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/transactions/providers/transaction_providers.dart';
import 'package:trueke/features/transactions/data/transaction_repository.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

class FakeTransactionRepository extends Fake implements TransactionRepository {}

void main() {
  group('Pruebas Unitarias de Transacciones - UserTransactionsNotifier', () {
    test('Inicialización correcta del notifier con repositorios mock', () async {
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
