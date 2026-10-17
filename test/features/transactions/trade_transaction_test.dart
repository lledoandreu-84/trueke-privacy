import 'package:flutter_test/flutter_test.dart';
import 'package:trueke/features/transactions/models/trade_transaction.dart';

void main() {
  group('TradeTransaction - Lógica de Caducidad Atómica (48h)', () {
    test(
      'Una oferta pendiente creada recientemente NO debe considerarse expirada',
      () {
        final transaction = TradeTransaction(
          id: 'tx_reciente',
          senderId: 'user_1',
          receiverId: 'user_2',
          offeredProductId: 'p1',
          requestedProductId: 'p2',
          status: 'pending',
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        );

        expect(transaction.isExpired, isFalse);
        expect(transaction.effectiveStatus, equals('pending'));
      },
    );

    test(
      'Una oferta pendiente creada hace más de 48 horas DEBE considerarse expirada de forma automática',
      () {
        final transaction = TradeTransaction(
          id: 'tx_antigua',
          senderId: 'user_1',
          receiverId: 'user_2',
          offeredProductId: 'p1',
          requestedProductId: 'p2',
          status: 'pending',
          createdAt: DateTime.now().subtract(const Duration(hours: 49)),
        );

        expect(transaction.isExpired, isTrue);
        expect(transaction.effectiveStatus, equals('expired'));
      },
    );

    test(
      'Una oferta ya aceptada o rechazada NO debe expirar aunque pasen más de 48 horas',
      () {
        final transactionAceptada = TradeTransaction(
          id: 'tx_aceptada',
          senderId: 'user_1',
          receiverId: 'user_2',
          offeredProductId: 'p1',
          requestedProductId: 'p2',
          status: 'accepted',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        );

        expect(transactionAceptada.isExpired, isFalse);
        expect(transactionAceptada.effectiveStatus, equals('accepted'));
      },
    );
  });
}
