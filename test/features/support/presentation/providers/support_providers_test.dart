import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/support/domain/repositories/support_repository.dart';
import 'package:trueke/features/support/presentation/providers/support_providers.dart';
import 'package:trueke/features/support/models/report_model.dart';

// Mock manual del repositorio de soporte para aislar las pruebas de mutaciones
class FakeSupportRepository implements SupportRepository {
  bool throwError = false;

  @override
  Future<void> submitReport(ReportModel report) async {
    if (throwError) {
      throw Exception('Network connection failure');
    }
    return Future.value(null);
  }

  @override
  Future<List<ReportModel>> fetchUserReports({required String userId}) async {
    if (throwError) {
      throw Exception('Network connection failure');
    }
    return [];
  }
}

void main() {
  group('SupportMutationNotifier - Pruebas de Flujo y Tolerancia a Fallos', () {
    late ProviderContainer container;
    late FakeSupportRepository fakeRepository;
    late ReportModel testReport;

    setUp(() {
      fakeRepository = FakeSupportRepository();
      container = ProviderContainer(
        overrides: [
          supportRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      testReport = ReportModel(
        id: 'rep_001',
        reporterId: 'usr_1',
        targetId: 'usr_2',
        targetType: 'user',
        reason: 'Comportamiento sospechoso',
        description: 'Intento de intercambio fuera de las normas de la app',
        status: 'pending',
        createdAt: DateTime.now(),
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'Debe transicionar a AsyncData con exito cuando el reporte se envia correctamente',
      () async {
        final notifier = container.read(supportMutationProvider.notifier);

        final result = await notifier.sendReport(testReport);

        expect(result, isTrue);
        final state = container.read(supportMutationProvider);
        expect(state, isA<AsyncData<void>>());
      },
    );

    test(
      'Debe transicionar a AsyncError y retornar false si el repositorio lanza un fallo de red',
      () async {
        fakeRepository.throwError = true;
        final notifier = container.read(supportMutationProvider.notifier);

        final result = await notifier.sendReport(testReport);

        expect(result, isFalse);
        final state = container.read(supportMutationProvider);
        expect(state, isA<AsyncError<void>>());
      },
    );
  });
}
