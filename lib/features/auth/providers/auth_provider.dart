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
    // 1. Desenfocar el teclado de forma segura
    FocusManager.instance.primaryFocus?.unfocus();

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = Supabase.instance.client;
      
      // 2. Invalidar preventivamente todos los proveedores de usuario y datos dependientes
      try {
        ref.invalidate(currentUserProvider);
        ref.invalidate(authUserIdProvider);
      } catch (_) {}

      // 3. Desconectar canales Realtime pendientes para evitar tráfico de socket huérfano
      try {
        await client.removeAllChannels();
      } catch (_) {}

      // 4. Pausa de seguridad para estabilizar los insets y la pila de renderizado
      await Future.delayed(const Duration(milliseconds: 150));

      // 5. Cierre de sesión local protegido contra caídas de socket nativas
      try {
        await client.auth.signOut(scope: SignOutScope.local);
      } catch (_) {}
    });
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(AuthController.new);
