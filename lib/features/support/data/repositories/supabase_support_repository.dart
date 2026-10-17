import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/report_model.dart';
import '../../domain/repositories/support_repository.dart';

class SupabaseSupportRepository implements SupportRepository {
  final SupabaseClient _client;
  static const _tableName = 'reports';
  final Future<void> Function(Map<String, dynamic> json)?
  mockSubmitReportInterceptor;

  SupabaseSupportRepository(this._client, {this.mockSubmitReportInterceptor});

  @override
  Future<void> submitReport(ReportModel report) async {
    if (mockSubmitReportInterceptor != null) {
      await mockSubmitReportInterceptor!(report.toJson());
      return;
    }
    await _client.from(_tableName).insert(report.toJson());
  }

  @override
  Future<List<ReportModel>> fetchUserReports({required String userId}) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('reporter_id', userId)
        .order('created_at', ascending: false);

    final List<dynamic> data = response as List<dynamic>;
    return data
        .map((json) => ReportModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
