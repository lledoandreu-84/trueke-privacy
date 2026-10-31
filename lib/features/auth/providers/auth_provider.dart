import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    // 1. Quitar el foco del teclado inmediatamente
    FocusManager.instance.primaryFocus?.unfocus();

    // IMPORTANTE: NO ponemos state = loading aquí para evitar que el router 
    // intente redirigir mientras el diálogo de confirmación sigue abierto en la UI.

    // 2. Dar un respiro de 600ms para que el diálogo de la UI se desmonte limpiamente
    await Future.delayed(const Duration(milliseconds: 600));

    // 3. Limpiar canales realtime activos
    try {
      await Supabase.instance.client.removeAllChannels();
    } catch (_) {}

    // 4. Borrado manual y seguro de la sesión en SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.contains('supabase') || key.contains('auth-token') || key.contains('sb-')) {
          await prefs.remove(key);
        }
      }
    } catch (_) {}

    // 5. Actualizar el estado al final de forma limpia para forzar la navegación al login
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(AuthController.new);
