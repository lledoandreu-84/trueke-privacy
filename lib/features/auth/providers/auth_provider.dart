import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  final authStateAsync = ref.watch(authStateProvider);
  return authStateAsync.when(
    data: (state) => state.session?.user,
    loading: () => Supabase.instance.client.auth.currentUser,
    error: (e, st) => null,
  );
});

final authUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.id;
});

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> signOut() async {
    // 1. Desenfocar y ocultar el teclado para evitar el choque de IME con el desmonte de UI
    FocusManager.instance.primaryFocus?.unfocus();
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = Supabase.instance.client;
      
      // 2. Desconectar canales Realtime pendientes
      try {
        await client.removeAllChannels();
      } catch (_) {}

      // 3. Cerrar sesión global en Supabase
      await client.auth.signOut(scope: SignOutScope.global);

      // 4. Invalidar providers para purgar caché
      ref.invalidate(currentUserProvider);
      ref.invalidate(authStateProvider);
      ref.invalidate(authUserIdProvider);
    });
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(AuthController.new);
