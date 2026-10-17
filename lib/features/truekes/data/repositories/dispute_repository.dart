import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../models/dispute_model.dart';

abstract class DisputeRepository {
  Future<DisputeModel> createDispute({
    required String truekeId,
    required String raisedBy,
    required String reason,
  });
  Stream<List<DisputeModel>> streamDisputesByTruekeId(String truekeId);
  Future<DisputeModel> updateDisputeStatus({
    required String disputeId,
    required DisputeStatus status,
  });
}

class SupabaseDisputeRepository implements DisputeRepository {
  final SupabaseClient _supabaseClient;

  SupabaseDisputeRepository(this._supabaseClient);

  @override
  Future<DisputeModel> createDispute({
    required String truekeId,
    required String raisedBy,
    required String reason,
  }) async {
    final response = await _supabaseClient
        .from('disputes')
        .insert({
          'trueke_id': truekeId,
          'raised_by': raisedBy,
          'reason': reason,
          'status': 'opened',
        })
        .select()
        .single();
    return DisputeModel.fromJson(response);
  }

  @override
  Stream<List<DisputeModel>> streamDisputesByTruekeId(String truekeId) {
    return _supabaseClient
        .from('disputes')
        .stream(primaryKey: ['id'])
        .eq('trueke_id', truekeId)
        .map((maps) => maps.map((map) => DisputeModel.fromJson(map)).toList());
  }

  @override
  Future<DisputeModel> updateDisputeStatus({
    required String disputeId,
    required DisputeStatus status,
  }) async {
    final String rawStatus = status == DisputeStatus.underReview
        ? 'under_review'
        : status.name;
    final response = await _supabaseClient
        .from('disputes')
        .update({
          'status': rawStatus,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', disputeId)
        .select()
        .single();
    return DisputeModel.fromJson(response);
  }
}

final disputeRepositoryProvider = Provider<DisputeRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseDisputeRepository(supabaseClient);
});
