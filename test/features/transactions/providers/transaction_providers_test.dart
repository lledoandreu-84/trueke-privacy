import 'package:trueke/features/offers/repositories/trade_offer_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/models/transaction.dart';
import 'package:trueke/features/transactions/data/transaction_repository.dart';
import 'package:trueke/features/transactions/providers/transaction_providers.dart';

// Simulación ligera del estado de autenticación de Supabase
class FakeUser extends User {
  FakeUser()
    : super(
        id: 'user-actual-123',
        appMetadata: {},
        userMetadata: {},
        aud: '',
        createdAt: '',
      );
}

class FakeAuth extends Fake implements GoTrueClient {
  @override
  User? get currentUser => FakeUser();
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  SupabaseQueryBuilder from(String table) => FakeSupabaseQueryBuilder();
}

class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  @override
  PostgrestFilterBuilder<PostgrestList> select([String? columns]) => FakePostgrestFilterBuilder();
}

class FakePostgrestFilterBuilder extends Fake implements PostgrestFilterBuilder<PostgrestList> {
  @override
  PostgrestFilterBuilder<PostgrestList> or(String filters, {String? referencedTable}) => this;

  @override
  PostgrestTransformBuilder<PostgrestList> order(String column, {bool ascending = true, bool nullsFirst = false, String? referencedTable}) => FakePostgrestTransformBuilder();
}

class FakePostgrestTransformBuilder extends Fake implements PostgrestTransformBuilder<PostgrestList> {
  @override
  Future<PostgrestList> then<T>(FutureOr<PostgrestList> Function(PostgrestList) onValue, {Function? onError}) async {
    return onValue([]);
  }
}
  @override
  GoTrueClient get auth => FakeAuth();
}

// Repositorio Simulado para pruebas limpias sin dependencias de red
class FakeTransactionRepository implements TransactionRepository {
  bool actualizarLlamado = false;
  String? ultimoTransactionId;
  String? ultimoProductId;
  String? ultimoEstado;

  @override
  Future<void> createTransaction(ProductTransaction transaction) async {}

  @override
  Future<List<ProductTransaction>> getUserTransactions(String userId) async {
    return [
      ProductTransaction(
        id: 'tx-123',
        productId: 'prod-456',
        productTitle: 'Bicicleta de Montaña',
        sellerId: 'user-vendedor',
        sellerName: 'David Vendedor',
        buyerId: 'user-actual-123',
        buyerName: 'Carlos Comprador',
        price: null,
        status: actualizarLlamado
            ? TransactionStatus.completed
            : TransactionStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<void> updateTransactionStatus(
    String transactionId,
    String status,
  ) async {}

  @override
  Future<void> actualizarEstadoTransaccionAtomica({
    required String transactionId,
    required String productId,
    required String nuevoEstado,
  }) async {
    actualizarLlamado = true;
    ultimoTransactionId = transactionId;
    ultimoProductId = productId;
    ultimoEstado = nuevoEstado;
  }
}

void main() {
  group('Pruebas Unitarias de Transacciones - UserTransactionsNotifier', () {
    late FakeTransactionRepository fakeRepository;
    late FakeSupabaseClient fakeClient;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = FakeTransactionRepository();
      fakeClient = FakeSupabaseClient();
      container = ProviderContainer(
        overrides: [
          supabaseClientProvider.overrideWithValue(fakeClient),
          transactionRepositoryProvider.overrideWithValue(fakeRepository),
          tradeOfferRepositoryProvider.overrideWithValue(TradeOfferRepository(fakeClient)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'procesarCambioEstadoTrueque invoca correctamente al repositorio e invalida estado',
      () async {
        container.listen(userTransactionsProvider, (prev, next) {});

        var estadoActual = await container.read(
          userTransactionsProvider.future,
        );
        expect(estadoActual.first.status, TransactionStatus.pending);
        expect(fakeRepository.actualizarLlamado, isFalse);

        await container
            .read(userTransactionsProvider.notifier)
            .procesarCambioEstadoTrueque(
              transactionId: 'tx-123',
              productId: 'prod-456',
              nuevoEstado: TransactionStatus.completed,
            );

        expect(fakeRepository.actualizarLlamado, isTrue);
        expect(fakeRepository.ultimoTransactionId, 'tx-123');
        expect(fakeRepository.ultimoProductId, 'prod-456');
        expect(fakeRepository.ultimoEstado, 'completed');

        final nuevoEstadoLista = await container.read(
          userTransactionsProvider.future,
        );
        expect(nuevoEstadoLista.first.status, TransactionStatus.completed);
      },
    );
  });
}
