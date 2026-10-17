import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/support/data/repositories/supabase_support_repository.dart';
import 'package:trueke/features/support/models/report_model.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

void main() {
  group('SupabaseSupportRepository - Persistencia e Intercepcion', () {
    late FakeSupabaseClient fakeClient;
    late ReportModel testReport;

    setUp(() {
      fakeClient = FakeSupabaseClient();
      testReport = ReportModel(
        id: 'rep_999',
        reporterId: 'usr_david_123',
        targetId: 'usr_hacker_777',
        targetType: 'user',
        reason: 'Spam masivo',
        description: 'Envia enlaces sospechosos por el chat de truekes',
        status: 'pending',
        createdAt: DateTime.now(),
      );
    });

    test(
      'Debe mapear a JSON e invocar el interceptor correctamente al enviar un reporte activo',
      () async {
        Map<String, dynamic>? capturedJson;

        final repository = SupabaseSupportRepository(
          fakeClient,
          mockSubmitReportInterceptor: (json) async {
            capturedJson = json;
          },
        );

        await repository.submitReport(testReport);

        expect(capturedJson, isNotNull);
        expect(capturedJson!['id'], equals('rep_999'));
        expect(capturedJson!['target_type'], equals('user'));
      },
    );

    test(
      'Debe propagar la excepcion controlada si la insercion remota del interceptor falla',
      () async {
        final repository = SupabaseSupportRepository(
          fakeClient,
          mockSubmitReportInterceptor: (json) async {
            throw Exception('Database error');
          },
        );

        expect(
          () => repository.submitReport(testReport),
          throwsA(isA<Exception>()),
        );
      },
    );
  });
}
