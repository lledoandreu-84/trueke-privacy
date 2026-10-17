import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_client.dart';

/// Servicio encargado de la infraestructura de pagos mixtos,
/// onboarding de cuentas de vendedor (Stripe Connect Express) y pasarela segura.
class StripeConnectService {
  final SupabaseClient _supabaseClient;

  StripeConnectService(this._supabaseClient);

  /// Genera una URL de onboarding para Stripe Connect Express.
  /// Permite al usuario configurar su cuenta bancaria para recibir dinero de trueques mixtos.
  Future<String> createConnectAccountLink({required String userId}) async {
    final response = await _supabaseClient.functions.invoke(
      'create-stripe-connect-account',
      body: {'userId': userId},
    );

    if (response.status != 200) {
      throw Exception(
        'Error al crear el link de Stripe Connect: ${response.data}',
      );
    }

    final data = response.data as Map<String, dynamic>;
    return data['url'] as String;
  }

  /// Inicializa un intento de pago para un trueque mixto (custodia/escrow de fondos).
  /// Calcula y desglosa el monto total y la comisión de la plataforma.
  Future<Map<String, dynamic>> initializeMixedPaymentIntent({
    required String tradeOfferId,
    required double amount,
    required String currency,
  }) async {
    final response = await _supabaseClient.functions.invoke(
      'initialize-mixed-payment',
      body: {
        'tradeOfferId': tradeOfferId,
        'amount': amount,
        'currency': currency,
      },
    );

    if (response.status != 200) {
      throw Exception(
        'Error al inicializar el intento de pago: ${response.data}',
      );
    }

    return response.data as Map<String, dynamic>;
  }
}

/// Proveedor clásico bajo la especificación estricta de Riverpod 3.
final stripeConnectServiceProvider = Provider<StripeConnectService>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return StripeConnectService(supabaseClient);
});
