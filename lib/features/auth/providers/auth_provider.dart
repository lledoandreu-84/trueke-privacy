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
  return authStateAsync.maybeWhen(
    data: (state) => state.session?.user,
    orElse: () {
      final client = ref.read(supabaseClientProvider);
      return client.auth.currentUser;
    },
  );
});

// Proveedor reactivo de ID derivado limpiamente de authStateProvider (sin bucles asíncronos paralelos)
final authUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.id;
});
