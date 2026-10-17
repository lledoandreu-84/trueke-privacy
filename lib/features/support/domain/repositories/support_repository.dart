import '../../models/report_model.dart';

abstract class SupportRepository {
  /// Envía un nuevo reporte o denuncia al sistema de soporte de Supabase.
  Future<void> submitReport(ReportModel report);

  /// Obtiene los reportes previos que ha realizado un usuario específico.
  Future<List<ReportModel>> fetchUserReports({required String userId});
}
