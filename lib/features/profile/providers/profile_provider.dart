import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../models/user_profile.dart';
import '../repositories/supabase_profile_repository.dart';

final supabaseProfileRepositoryProvider =
    Provider.autoDispose<SupabaseProfileRepository>((ref) {
      final client = ref.watch(supabaseClientProvider);
      return SupabaseProfileRepository(client);
    });

final userProfileProvider = FutureProvider.autoDispose
    .family<UserProfile, String>((ref, userId) async {
      final repository = ref.watch(supabaseProfileRepositoryProvider);
      return repository.getProfile(userId);
    });

class ProfileMutationNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> updateProfile({required UserProfile profile}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(supabaseProfileRepositoryProvider);
      await repository.updateProfile(profile);
      ref.invalidate(userProfileProvider(profile.id));
    });
  }
}

final profileMutationProvider =
    AsyncNotifierProvider.autoDispose<ProfileMutationNotifier, void>(() {
      return ProfileMutationNotifier();
    });
