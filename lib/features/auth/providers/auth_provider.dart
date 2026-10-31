import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../auth_service.dart';

// Proveedor del servicio inyectado
final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});

// Única fuente de verdad en tiempo real para el estado de autenticación
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

// Proveedor síncrono del usuario actual derivado de la única fuente de verdad
final currentUserProvider = Provider<User?>((ref) {
  final authStateAsync = ref.watch(authStateProvider);
  return authStateAsync.when(
    data: (state) => state.session?.user,
    loading: () => Supabase.instance.client.auth.currentUser,
    error: (e, st) => null,
  );
});

// Proveedor reactivo de ID derivado limpiamente
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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 1. Cerrar sesión globalmente en Supabase
      await Supabase.instance.client.auth.signOut(scope: SignOutScope.global);
      
      // 2. Invalidar todos los providers de sesión para purgar cachés y streams zombis
      ref.invalidate(currentUserProvider);
      ref.invalidate(authStateProvider);
      ref.invalidate(authUserIdProvider);
    });
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(AuthController.new);
