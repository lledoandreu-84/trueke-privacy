import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../auth_service.dart';

// Proveedor del servicio inyectado heredado
final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});

// Flujo en tiempo real unificado de cambios de sesión
final authStateProvider = StreamProvider<AuthState>((ref) async* {
  final client = ref.watch(supabaseClientProvider);
  final initialSession = client.auth.currentSession;
  if (initialSession != null) {
    yield AuthState(AuthChangeEvent.initialSession, initialSession);
  }
  yield* client.auth.onAuthStateChange;
});

// Proveedor síncrono del usuario actual conectado al estado reactivo del stream
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

// Proveedor reactivo asíncrono de ID exigido por la arquitectura del MVP
final authUserIdProvider = StreamProvider<String?>((ref) async* {
  final client = ref.watch(supabaseClientProvider);
  yield client.auth.currentUser?.id;
  await for (final authState in client.auth.onAuthStateChange) {
    yield authState.session?.user.id;
  }
});
