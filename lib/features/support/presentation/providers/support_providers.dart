import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../data/repositories/supabase_support_repository.dart';
import '../../domain/repositories/support_repository.dart';
import '../../models/report_model.dart';

// Provider base para el repositorio de soporte
final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSupportRepository(client);
});

// Notifier asíncrono para gestionar las acciones y peticiones de soporte
class SupportMutationNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Estado inicial inactivo / ocioso
  }

  /// Envía un nuevo reporte y controla los estados de carga y error asíncronos
  Future<bool> sendReport(ReportModel report) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(supportRepositoryProvider);
      await repository.submitReport(report);
      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

// Provider global para controlar la ejecución de las mutaciones de soporte
final supportMutationProvider =
    AsyncNotifierProvider<SupportMutationNotifier, void>(
      SupportMutationNotifier.new,
    );
