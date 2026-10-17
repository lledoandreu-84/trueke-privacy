import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/profile/repositories/supabase_profile_repository.dart';
import 'package:trueke/features/profile/models/user_profile.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

void main() {
  group('SupabaseProfileRepository - Persistencia de Datos de Usuario', () {
    late FakeSupabaseClient fakeClient;

    setUp(() {
      fakeClient = FakeSupabaseClient();
    });

    test(
      'Debe deserializar correctamente un perfil de usuario desde un JSON simulado',
      () async {
        final repository = SupabaseProfileRepository(
          fakeClient,
          mockGetProfileInterceptor: (id) async => {
            'id': id,
            'display_name': 'David Andreu',
            'email': 'david@trueke.es',
            'avatar_url': 'https://supabase.co',
            'bio': 'Desarrollador de Trueke MVP',
            'average_rating': 4.8,
            'total_ratings': 12,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        );

        final profile = await repository.getProfile('usr_david_123');

        expect(profile.id, equals('usr_david_123'));
        expect(profile.displayName, equals('David Andreu'));
      },
    );

    test(
      'Debe omitir el campo created_at al preparar la mutacion de actualizacion',
      () async {
        Map<String, dynamic>? capturedUpdates;

        final repository = SupabaseProfileRepository(
          fakeClient,
          mockUpdateProfileInterceptor: (updates) async {
            capturedUpdates = updates;
          },
        );

        final mockProfile = UserProfile(
          id: 'usr_david_123',
          displayName: 'David Andreu',
          email: 'david@trueke.es',
          avatarUrl: '',
          bio: '',
          averageRating: 5.0,
          totalRatings: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.updateProfile(mockProfile);

        expect(capturedUpdates, isNotNull);
        expect(capturedUpdates!.containsKey('created_at'), isFalse);
        expect(capturedUpdates!.containsKey('updated_at'), isTrue);
      },
    );
  });
}
