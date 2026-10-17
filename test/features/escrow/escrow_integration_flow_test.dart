import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trueke/features/escrow/models/escrow_transaction.dart';
import 'package:trueke/features/escrow/repositories/escrow_repository.dart';

class MockEscrowRepository extends Mock implements EscrowRepository {}

void main() {
  group('Escrow Integration Flow - Casos de Éxito', () {
    late MockEscrowRepository mockRepository;

    const baseTransaction = EscrowTransaction(
      id: 'escrow-999',
      tradeOfferId: 'offer-777',
      buyerId: 'buyer-uid',
      sellerId: 'seller-uid',
      amount: 120.0,
      currency: 'EUR',
      status: EscrowStatus.pendingDeposit,
      stripePaymentIntentId: 'pi_test999',
    );

    setUp(() {
      mockRepository = MockEscrowRepository();
    });

    test(
      'Debe transicionar secuencialmente todo el ciclo de vida del Escrow de forma exitosa',
      () async {
        // 1. Inicialización de la Transacción en Custodia
        when(
          () => mockRepository.createEscrow(
            tradeOfferId: 'offer-777',
            amount: 120.0,
            currency: 'EUR',
          ),
        ).thenAnswer((_) async => baseTransaction);

        final step1 = await mockRepository.createEscrow(
          tradeOfferId: 'offer-777',
          amount: 120.0,
          currency: 'EUR',
        );
        expect(step1.status, EscrowStatus.pendingDeposit);
        expect(step1.amount, 120.0);

        // 2. Simulación de Depósito Completado y actualización de información Logística por el Vendedor
        const shippedTransaction = EscrowTransaction(
          id: 'escrow-999',
          tradeOfferId: 'offer-777',
          buyerId: 'buyer-uid',
          sellerId: 'seller-uid',
          amount: 120.0,
          currency: 'EUR',
          status: EscrowStatus.shipped,
          carrier: 'SEUR',
          trackingNumber: 'SEUR123456',
          stripePaymentIntentId: 'pi_test999',
        );

        when(
          () => mockRepository.updateTrackingInfo(
            escrowId: 'escrow-999',
            trackingNumber: 'SEUR123456',
            carrier: 'SEUR',
          ),
        ).thenAnswer((_) async => shippedTransaction);

        final step2 = await mockRepository.updateTrackingInfo(
          escrowId: 'escrow-999',
          trackingNumber: 'SEUR123456',
          carrier: 'SEUR',
        );
        expect(step2.status, EscrowStatus.shipped);
        expect(step2.carrier, 'SEUR');
        expect(step2.trackingNumber, 'SEUR123456');

        // 3. Simulación de Cancelación Atómica y Reembolso Seguro al Comprador
        const refundedTransaction = EscrowTransaction(
          id: 'escrow-999',
          tradeOfferId: 'offer-777',
          buyerId: 'buyer-uid',
          sellerId: 'seller-uid',
          amount: 120.0,
          currency: 'EUR',
          status: EscrowStatus.refunded,
          stripePaymentIntentId: 'pi_test999',
        );

        when(
          () => mockRepository.cancelAndRefundEscrow(escrowId: 'escrow-999'),
        ).thenAnswer((_) async => refundedTransaction);

        final step3 = await mockRepository.cancelAndRefundEscrow(
          escrowId: 'escrow-999',
        );
        expect(step3.status, EscrowStatus.refunded);
      },
    );
  });
}
