import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../models/wallet_model.dart';
import '../repositories/wallet_repository.dart';
import '../../../features/auth/auth_service.dart';

// Provider base para el repositorio financiero
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseWalletRepository(client);
});

// Provider familiar asincrono para observar en tiempo real la billetera de cualquier usuario
final userWalletProvider = FutureProvider.family<WalletModel, String>((
  ref,
  userId,
) async {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.getWallet(userId);
});

// Notifier asincrono para controlar mutaciones de saldo, recargas y depasitos
class WalletMutationNotifier extends AsyncNotifier<void> {
  @override
  void build() {
    // Estado ocioso inicial sincrono conforme a los lints de Riverpod
  }

  /// Realiza un deposito virtual y refresca de forma automatica la billetera del usuario
  Future<bool> depositFunds({required double amount}) async {
    state = const AsyncValue.loading();
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) throw Exception('Sesión expirada o no válida.');

      final repository = ref.read(walletRepositoryProvider);
      await repository.depositFunds(userId: currentUser.id, amount: amount);

      // Invalida la cache de forma sincronizada para forzar el refresco en la UI
      ref.invalidate(userWalletProvider(currentUser.id));

      state = const AsyncValue.data(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

// Provider global para orquestar las mutaciones de la billetera desde las pantallas
final walletMutationProvider =
    AsyncNotifierProvider<WalletMutationNotifier, void>(
      WalletMutationNotifier.new,
    );
