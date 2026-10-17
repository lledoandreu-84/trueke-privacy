import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueke/features/truekes/data/models/trueke_model.dart';
import 'package:trueke/features/truekes/data/datasources/local_trueke_data_source.dart';
import 'package:trueke/features/truekes/data/repositories/trueke_repository.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

void main() {
  SharedPreferences.setMockInitialValues({});

  final testTruekeJson = {
    'id': 'tk_test_101',
    'sender_id': 'usr_1',
    'receiver_id': 'usr_2',
    'status': 'opened',
    'created_at': '2026-10-08T12:00:00.000Z',
    'updated_at': '2026-10-08T12:00:00.000Z',
  };

  group('TruekeRepository Hybrid Persistence Tests', () {
    late FakeSupabaseClient fakeClient;
    late LocalTruekeDataSource localDataSource;
    late SharedPreferences prefs;

    setUp(() async {
      prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      fakeClient = FakeSupabaseClient();
      localDataSource = LocalTruekeDataSource(prefs);
    });

    test(
      'Debe retornar datos remotos y actualizar la caché local cuando la red está activa',
      () async {
        final repository = TruekeRepository(
          fakeClient,
          localDataSource,
          mockFetchMock: () async => [testTruekeJson],
        );

        final result = await repository.fetchMyTruekes('usr_1');

        expect(result, isNotEmpty);
        expect(result.first.id, equals('tk_test_101'));

        final cached = await localDataSource.getCachedTruekes();
        expect(cached, isNotEmpty);
        expect(cached.first.id, equals('tk_test_101'));
      },
    );

    test(
      'Debe activar el fallback de lectura offline recuperando los datos de la caché local si Supabase falla',
      () async {
        final truekeModel = TruekeModel.fromJson(testTruekeJson);
        await localDataSource.cacheTruekes([truekeModel]);

        final repository = TruekeRepository(
          fakeClient,
          localDataSource,
          mockFetchMock: () async =>
              throw Exception('Network connection failure'),
        );

        final result = await repository.fetchMyTruekes('usr_1');

        expect(result, isNotEmpty);
        expect(result.first.id, equals('tk_test_101'));
      },
    );
  });
}
