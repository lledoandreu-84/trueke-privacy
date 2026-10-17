import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/truekes/data/repositories/trueke_repository.dart';
import 'package:trueke/features/truekes/data/models/payment_order_model.dart';

abstract class PaymentState {
  const PaymentState();
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentProcessing extends PaymentState {
  const PaymentProcessing();
}

class PaymentSuccess extends PaymentState {
  final PaymentOrderModel order;
  const PaymentSuccess(this.order);
}

class PaymentError extends PaymentState {
  final String message;
  const PaymentError(this.message);
}

class PaymentNotifier extends Notifier<PaymentState> {
  @override
  PaymentState build() {
    return const PaymentInitial();
  }

  Future<void> processTruekePayment({
    required String truekeId,
    required String userId,
    required double amount,
  }) async {
    state = const PaymentProcessing();
    try {
      final repository = ref.read(truekeRepositoryProvider);

      final order = await repository.createPaymentOrder(
        truekeId: truekeId,
        userId: userId,
        amount: amount,
        externalIntentId:
            'mock_intent_${DateTime.now().millisecondsSinceEpoch}',
      );

      await repository.updatePaymentOrderStatus(
        order.id,
        PaymentOrderStatus.succeeded,
      );

      final confirmedOrder = PaymentOrderModel(
        id: order.id,
        truekeId: order.truekeId,
        userId: order.userId,
        amount: order.amount,
        currency: order.currency,
        status: PaymentOrderStatus.succeeded,
        externalIntentId: order.externalIntentId,
        createdAt: order.createdAt,
        updatedAt: DateTime.now(),
      );

      state = PaymentSuccess(confirmedOrder);
    } catch (e) {
      state = PaymentError(e.toString());
    }
  }

  void resetState() {
    state = const PaymentInitial();
  }
}

final paymentNotifierProvider = NotifierProvider<PaymentNotifier, PaymentState>(
  () {
    return PaymentNotifier();
  },
);
