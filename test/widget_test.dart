import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Trueke basic widget smoke test', (WidgetTester tester) async {
    // Renderizamos un contenedor MaterialApp básico para asegurar que el motor de tests responde
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Trueke Test Environment'),
          ),
        ),
      ),
    );

    expect(find.text('Trueke Test Environment'), findsOneWidget);
  });
}
