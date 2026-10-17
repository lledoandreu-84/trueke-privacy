import 'package:flutter_test/flutter_test.dart';
import 'package:trueke/features/truekes/data/models/trueke_model.dart';
import 'package:trueke/features/truekes/data/models/dispute_model.dart';
import 'package:trueke/features/truekes/data/models/payment_order_model.dart';

void main() {
  group('Pruebas Unitarias de Resiliencia Offline - TRUEKE', () {
    test('Debe deserializar correctamente el histórico de caché local', () {
      final Map<String, dynamic> mockJson = {
        'id': '00000000-0000-0000-0000-000000000000',
        'sender_id': 'sender_123',
        'receiver_id': 'receiver_456',
        'status': 'completed',
        'created_at': '2026-09-28T12:00:00.000Z',
        'updated_at': '2026-09-28T12:00:00.000Z',
      };

      final model = TruekeModel.fromJson(mockJson);

      expect(model.id, '00000000-0000-0000-0000-000000000000');
      expect(model.status, TruekeStatus.completed);
    });

    test(
      'Debe deserializar correctamente el modelo de disputas de arbitraje',
      () {
        final Map<String, dynamic> mockDisputeJson = {
          'id': 'dispute_id_abc',
          'trueke_id': 'trueke_id_123',
          'raised_by': 'user_id_789',
          'reason': 'El producto no coincide con las especificaciones visuales',
          'status': 'under_review',
          'created_at': '2026-09-28T12:00:00.000Z',
          'updated_at': '2026-09-28T12:00:00.000Z',
        };

        final dispute = DisputeModel.fromJson(mockDisputeJson);

        expect(dispute.status, DisputeStatus.underReview);
        expect(dispute.reason, contains('especificaciones visuales'));
      },
    );

    test(
      'Debe deserializar correctamente el modelo de intenciones de pago',
      () {
        final Map<String, dynamic> mockPaymentJson = {
          'id': 'order_id_999',
          'trueke_id': 'trueke_id_123',
          'user_id': 'user_id_789',
          'amount': 25.50,
          'currency': 'EUR',
          'status': 'succeeded',
          'external_intent_id': 'mock_intent_stripe_111',
          'created_at': '2026-09-28T12:00:00.000Z',
          'updated_at': '2026-09-28T12:00:00.000Z',
        };

        final payment = PaymentOrderModel.fromJson(mockPaymentJson);

        expect(payment.amount, 25.50);
        expect(payment.status, PaymentOrderStatus.succeeded);
      },
    );
  });
}
