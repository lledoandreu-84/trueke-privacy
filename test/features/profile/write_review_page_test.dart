import 'package:trueke/features/transactions/providers/reviews_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/profile/models/user_profile.dart';
import 'package:trueke/features/profile/providers/profile_provider.dart';
import 'package:trueke/features/profile/repositories/supabase_profile_repository.dart';
import 'package:trueke/features/profile/views/write_review_page.dart';
import 'package:trueke/models/user_review.dart';

// Modificar la herencia para alinearse con el tipo estricto del provider del MVP
class FakeProfileRepository extends Fake implements SupabaseProfileRepository {
  bool createReviewCalled = false;
  String? capturedReceiverId;
  double? capturedRating;
  String? capturedComment;

  @override
  Future<UserProfile> getProfile(String id) async {
    return UserProfile(
      id: id,
      email: 'test@trueke.com',
      displayName: 'Usuario Test',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {}

  @override
  Future<List<UserReview>> getUserReviews(String userId) async => [];

  @override
  Future<void> createReview({
    required String receiverId,
    required double rating,
    required String comment,
  }) async {
    createReviewCalled = true;
    capturedReceiverId = receiverId;
    capturedRating = rating;
    capturedComment = comment;
  }
}

void main() {
  final testProfile = UserProfile(
    id: 'user-receiver-456',
    email: 'test@trueke.com',
    displayName: 'Usuario Test',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  testWidgets(
    'Debe mostrar snackbar de validación si el comentario está vacío',
    (WidgetTester tester) async {
      final fakeRepository = FakeProfileRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseProfileRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: const MaterialApp(
            home: WriteReviewPage(receiverId: 'user-receiver-456'),
          ),
        ),
      );

      await tester.tap(find.text('Enviar Valoración'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, escribe un comentario.'), findsOneWidget);
      expect(fakeRepository.createReviewCalled, isFalse);
    },
  );

  testWidgets(
    'Debe invocar createReview con los parámetros correctos cuando los datos son válidos',
    (WidgetTester tester) async {
      final fakeRepository = FakeProfileRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseProfileRepositoryProvider.overrideWithValue(fakeRepository),
            // Sobreescribir el provider del perfil para evitar llamadas a la red durante el invalidate asíncrono
            userProfileProvider(
              'user-receiver-456',
            ).overrideWith((ref) => testProfile),
            userReviewsProvider('user-receiver-456').overrideWith((ref) => []),
          ],
          child: const MaterialApp(
            home: WriteReviewPage(receiverId: 'user-receiver-456'),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextField),
        'Excelente intercambio, muy rápido',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enviar Valoración'));
      await tester.pump();

      expect(fakeRepository.createReviewCalled, isTrue);
      expect(fakeRepository.capturedReceiverId, 'user-receiver-456');
      expect(
        fakeRepository.capturedComment,
        'Excelente intercambio, muy rápido',
      );
      expect(fakeRepository.capturedRating, 5.0);
    },
  );
}
