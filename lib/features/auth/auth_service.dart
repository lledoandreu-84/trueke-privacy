import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      // Si el usuario ya existe, Supabase a veces retorna un usuario con identities vacías según la config
      if (response.user != null &&
          (response.user!.identities == null || response.user!.identities!.isEmpty)) {
        throw const AuthException('Este correo electrónico ya está registrado. Por favor, inicia sesión.');
      }

      return response;
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered') ||
          e.message.toLowerCase().contains('user already exists')) {
        throw const AuthException('Este correo electrónico ya está registrado. Por favor, inicia sesión.');
      }
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        throw const AuthException('Correo o contraseña incorrectos. Por favor, verifica tus datos.');
      }
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
