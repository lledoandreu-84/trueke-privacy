import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/reviews/data/review_repository.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

void main() {
  group('ReviewRepository - Calculos de Confianza y Reputacion', () {
    late FakeSupabaseClient fakeClient;

    setUp(() {
      fakeClient = FakeSupabaseClient();
    });

    test(
      'Debe calcular con precision matematica la media incluyendo valores decimales',
      () async {
        final repository = ReviewRepository(
          fakeClient,
          mockGetReviewsInterceptor: (userId) async => [
            {'rating': 4.5},
            {'rating': 5.0},
            {'rating': 4.0},
          ],
        );

        final average = await repository.getUserAverageRating('usr_david_123');

        // (4.5 + 5.0 + 4.0) / 3 = 13.5 / 3 = 4.5
        expect(average, equals(4.5));
      },
    );

    test(
      'Debe retornar 0.0 sin romper la aplicacion si el listado de reseñas viene vacio',
      () async {
        final repository = ReviewRepository(
          fakeClient,
          mockGetReviewsInterceptor: (userId) async => [],
        );

        final average = await repository.getUserAverageRating(
          'usr_new_user_777',
        );

        expect(average, equals(0.0));
      },
    );
  });
}
