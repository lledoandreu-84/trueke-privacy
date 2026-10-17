import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/auth/auth_page.dart';

void main() {
  group('Auth: Validación de Formularios en AuthPage', () {
    Widget createAuthPageWidget() {
      return const ProviderScope(
        child: MaterialApp(home: Scaffold(body: AuthPage())),
      );
    }

    testWidgets(
      'Debe mostrar un mensaje de error si el email está vacío o no contiene una arroba',
      (WidgetTester tester) async {
        await tester.pumpWidget(createAuthPageWidget());
        await tester.pumpAndSettle();

        // Buscamos el botón de iniciar sesión para disparar la validación del formulario
        final submitButton = find.text('Iniciar sesión');
        expect(submitButton, findsOneWidget);

        await tester.tap(submitButton);
        await tester.pump();

        // Debe saltar el validador de email vacío
        expect(find.text('Introduce tu correo electrónico.'), findsOneWidget);

        // Introducimos un correo inválido sin arroba
        final emailField = find.byType(TextFormField).first;
        await tester.enterText(emailField, 'correo_invalido.com');
        await tester.tap(submitButton);
        await tester.pump();

        // Debe saltar el validador de estructura de email
        expect(find.text('Introduce un correo válido.'), findsOneWidget);
      },
    );

    testWidgets('Debe exigir una contraseña con un mínimo de 6 caracteres', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createAuthPageWidget());
      await tester.pumpAndSettle();

      final submitButton = find.text('Iniciar sesión');
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      // Introducemos un email correcto pero una contraseña corta de 3 letras
      await tester.enterText(emailField, 'test@trueke.com');
      await tester.enterText(passwordField, '123');

      await tester.tap(submitButton);
      await tester.pump();

      expect(
        find.text('La contraseña debe tener al menos 6 caracteres.'),
        findsOneWidget,
      );
    });
  });
}
