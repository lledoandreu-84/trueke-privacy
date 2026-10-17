import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/profile/models/user_profile.dart';
import 'package:trueke/features/profile/providers/profile_provider.dart';
import 'package:trueke/features/profile/presentation/screens/edit_profile_screen.dart';

// Mock manual del Notifier para controlar con exactitud los estados asíncronos en el test
class FakeProfileMutationNotifier extends ProfileMutationNotifier {
  final Completer<void> _completer = Completer<void>();
  bool wasUpdateCalled = false;
  UserProfile? capturedProfile;

  @override
  FutureOr<void> build() {}

  @override
  Future<void> updateProfile({required UserProfile profile}) async {
    wasUpdateCalled = true;
    capturedProfile = profile;
    state = const AsyncValue.loading();
    try {
      await _completer.future;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void completeMutation() => _completer.complete();
}

void main() {
  final testProfile = UserProfile(
    id: 'user-123',
    email: 'david@trueke.com',
    displayName: 'David',
    bio: 'Desarrollador Flutter',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  testWidgets('Debe mostrar error de validación cuando el nombre está vacío', (
    WidgetTester tester,
  ) async {
    final fakeNotifier = FakeProfileMutationNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileMutationProvider.overrideWith(() => fakeNotifier)],
        child: MaterialApp(home: EditProfileScreen(profile: testProfile)),
      ),
    );

    // Limpiar el campo de texto del nombre público
    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.pumpAndSettle();

    // Presionar el botón de guardar
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    // Verificar que aparece el mensaje de validación esperado
    expect(find.text('El nombre no puede estar vacío'), findsOneWidget);
    expect(fakeNotifier.wasUpdateCalled, isFalse);
  });

  testWidgets(
    'Debe deshabilitar los campos de texto durante el estado de carga (isLoading)',
    (WidgetTester tester) async {
      final fakeNotifier = FakeProfileMutationNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileMutationProvider.overrideWith(() => fakeNotifier)],
          child: MaterialApp(home: EditProfileScreen(profile: testProfile)),
        ),
      );

      // Modificar el texto y guardar para inducir el estado de carga controlado
      await tester.enterText(
        find.byType(TextFormField).first,
        'David Modificado',
      );
      await tester.tap(find.text('Guardar'));
      await tester.pump(); // Procesar el inicio de la mutación (loading)

      // Verificar que los TextFormFields tienen la propiedad enabled en false evaluando su decoración o interactividad
      final nameTextField = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField).first,
          matching: find.byType(TextField),
        ),
      );

      expect(nameTextField.enabled, isFalse);
      expect(fakeNotifier.wasUpdateCalled, isTrue);
      expect(fakeNotifier.capturedProfile?.displayName, 'David Modificado');
    },
  );
}
