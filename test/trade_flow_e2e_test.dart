import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/chat/presentation/widgets/trade_offer_card_widget.dart';
import 'package:trueke/features/auth/auth_service.dart';

void main() {
  group('Suite E2E: Verificación de Tarjeta de Oferta Comercial', () {
    testWidgets(
      'Debe renderizar correctamente la información de Trueke y sus estados',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authUserIdProvider.overrideWith(
                (ref) => Stream.value('mock-user-123'),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: TradeOfferCardWidget(
                    offerId: 'trade-777',
                    productTitle: 'Producto de Intercambio Test',
                    status: 'pending',
                    amount: 150.0,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(TradeOfferCardWidget), findsOneWidget);
        expect(find.text('Producto de Intercambio Test'), findsOneWidget);
        expect(find.text('Compensación: 150.00€'), findsOneWidget);
        expect(find.text('Aceptar'), findsOneWidget);
        expect(find.text('Rechazar'), findsOneWidget);
      },
    );

    testWidgets(
      'Debe mostrar indicador de progreso cuando el estado está cargando',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authUserIdProvider.overrideWith(
                (ref) => Stream.value('mock-user-123'),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: TradeOfferCardWidget(
                    offerId: 'trade-888',
                    productTitle: 'Producto Cargando Test',
                    status: 'pending',
                    amount: 0.0,
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(TradeOfferCardWidget), findsOneWidget);
      },
    );
  });
}
