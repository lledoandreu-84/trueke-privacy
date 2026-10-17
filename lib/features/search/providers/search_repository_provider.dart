import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/search/repositories/search_repository.dart';
import 'package:trueke/features/search/repositories/supabase_search_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSearchRepository(client);
});

// Mock provisional compatible con versiones estrictas de Riverpod
final notificationsProvider = Provider<int>((ref) => 0);
