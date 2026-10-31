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

// Stream puro de Supabase blindado
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

final authUserIdProvider = StreamProvider<String?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((event) => event.session?.user.id);
});

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> signOut() async {
    // 1. Quitar el foco del teclado inmediatamente
    FocusManager.instance.primaryFocus?.unfocus();

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final client = Supabase.instance.client;

      // 2. Limpiar canales realtime de forma totalmente aislada
      try {
        await client.removeAllChannels();
      } catch (_) {}

      // 3. Forzar un respiro de 300ms al motor de Dart/Impeller para vaciar la cola de eventos JNI
      await Future.delayed(const Duration(milliseconds: 300));

      // 4. Ejecutar el signOut localmente sin bloquear el hilo principal
      try {
        await client.auth.signOut(scope: SignOutScope.local);
      } catch (_) {}
    });
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(AuthController.new);
