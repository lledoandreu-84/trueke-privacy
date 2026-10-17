import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueke/features/escrow/models/escrow_transaction.dart';
import 'package:trueke/features/escrow/repositories/escrow_repository.dart';

class MockEscrowRepository extends Mock implements EscrowRepository {}

void main() {
  late MockEscrowRepository mockRepository;

  setUp(() {
    mockRepository = MockEscrowRepository();
  });

  group('EscrowRepository Tests', () {
    const mockTransaction = EscrowTransaction(
      id: 'escrow-123',
      tradeOfferId: 'offer-456',
      buyerId: 'user-buyer',
      sellerId: 'user-seller',
      amount: 50.0,
      currency: 'EUR',
      status: EscrowStatus.pendingDeposit,
      stripePaymentIntentId: 'pi_test123',
    );

    test(
      'getEscrowByTradeOfferId devuelve un EscrowTransaction valido',
      () async {
        when(
          () => mockRepository.getEscrowByTradeOfferId('offer-456'),
        ).thenAnswer((_) async => mockTransaction);

        final result = await mockRepository.getEscrowByTradeOfferId(
          'offer-456',
        );

        expect(result.id, 'escrow-123');
        expect(result.status, EscrowStatus.pendingDeposit);
        expect(result.amount, 50.0);
      },
    );

    test(
      'createEscrow genera una nueva transaccion en custodia pendiente de deposito',
      () async {
        when(
          () => mockRepository.createEscrow(
            tradeOfferId: 'offer-456',
            amount: 50.0,
            currency: 'EUR',
          ),
        ).thenAnswer((_) async => mockTransaction);

        final result = await mockRepository.createEscrow(
          tradeOfferId: 'offer-456',
          amount: 50.0,
          currency: 'EUR',
        );

        expect(result.id, 'escrow-123');
        expect(result.status, EscrowStatus.pendingDeposit);
      },
    );

    test(
      'updateTrackingInfo actualiza los datos logisticos y devuelve la transaccion',
      () async {
        const shippedTransaction = EscrowTransaction(
          id: 'escrow-123',
          tradeOfferId: 'offer-456',
          buyerId: 'user-buyer',
          sellerId: 'user-seller',
          amount: 50.0,
          currency: 'EUR',
          status: EscrowStatus.shipped,
          stripePaymentIntentId: 'pi_test123',
        );

        when(
          () => mockRepository.updateTrackingInfo(
            escrowId: 'escrow-123',
            trackingNumber: 'RR123456789ES',
            carrier: 'CORREOS',
          ),
        ).thenAnswer((_) async => shippedTransaction);

        final result = await mockRepository.updateTrackingInfo(
          escrowId: 'escrow-123',
          trackingNumber: 'RR123456789ES',
          carrier: 'CORREOS',
        );

        expect(result.id, 'escrow-123');
        expect(result.status, EscrowStatus.shipped);
      },
    );

    test(
      'cancelAndRefundEscrow transiciona el estado de la transaccion a refunded',
      () async {
        const refundedTransaction = EscrowTransaction(
          id: 'escrow-123',
          tradeOfferId: 'offer-456',
          buyerId: 'user-buyer',
          sellerId: 'user-seller',
          amount: 50.0,
          currency: 'EUR',
          status: EscrowStatus.refunded,
          stripePaymentIntentId: 'pi_test123',
        );

        when(
          () => mockRepository.cancelAndRefundEscrow(escrowId: 'escrow-123'),
        ).thenAnswer((_) async => refundedTransaction);

        final result = await mockRepository.cancelAndRefundEscrow(
          escrowId: 'escrow-123',
        );

        expect(result.id, 'escrow-123');
        expect(result.status, EscrowStatus.refunded);
      },
    );
  });
}
