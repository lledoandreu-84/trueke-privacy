import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/transaction.dart';
import '../../offers/repositories/trade_offer_repository.dart';
import '../../offers/models/trade_offer.dart';

// Proveedor del cliente de Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});


// Alias de compatibilidad para repositorios de transacciones
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(supabaseClientProvider));
});

final tradeOfferRepositoryProvider = Provider<TradeOfferRepository>((ref) {
  return TradeOfferRepository(ref.watch(supabaseClientProvider));
});

final userTransactionsProvider =
    AsyncNotifierProvider<UserTransactionsNotifier, List<ProductTransaction>>(
      () {
        return UserTransactionsNotifier();
      },
    );

class UserTransactionsNotifier extends AsyncNotifier<List<ProductTransaction>> {
  @override
  Future<List<ProductTransaction>> build() async {
    final client = ref.watch(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) return [];
    
    // Obtenemos las ofertas desde el repositorio unificado de trade_offers
    final offers = await ref.read(tradeOfferRepositoryProvider).fetchOffersByUserId(user.id);
    
    // Mapeamos TradeOffer a ProductTransaction para mantener compatibilidad con la UI de Mi Cuenta / Historial
    return offers.map((o) => ProductTransaction(
      id: o.id,
      productId: o.receiverProductId,
      productTitle: 'Intercambio de Artículo',
      sellerId: o.receiverId,
      sellerName: 'Vendedor',
      buyerId: o.senderId,
      buyerName: 'Comprador',
      price: o.additionalCash,
      status: o.status == TradeOfferStatus.accepted 
          ? TransactionStatus.accepted 
          : (o.status == TradeOfferStatus.declined ? TransactionStatus.cancelled : TransactionStatus.pending),
      createdAt: o.createdAt,
      updatedAt: o.createdAt,
    )).toList();
  }

  Future<void> createOffer(ProductTransaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Creamos la oferta de forma unificada (crea oferta, chat y mensaje inicial atómicamente)
      await ref
          .read(tradeOfferRepositoryProvider)
          .createOffer(
            receiverId: transaction.sellerId,
            senderProductId: transaction.productId, // O producto emisor si aplica
            receiverProductId: transaction.productId,
            additionalCash: transaction.price ?? 0.0,
          );

      final client = ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;
      
      final offers = await ref.read(tradeOfferRepositoryProvider).fetchOffersByUserId(user?.id ?? '');
      return offers.map((o) => ProductTransaction(
        id: o.id,
        productId: o.receiverProductId,
        productTitle: 'Intercambio de Artículo',
        sellerId: o.receiverId,
        sellerName: 'Vendedor',
        buyerId: o.senderId,
        buyerName: 'Comprador',
        price: o.additionalCash,
        status: o.status == TradeOfferStatus.accepted 
            ? TransactionStatus.accepted 
            : (o.status == TradeOfferStatus.declined ? TransactionStatus.cancelled : TransactionStatus.pending),
        createdAt: o.createdAt,
        updatedAt: o.createdAt,
      )).toList();
    });
  }

  Future<void> changeStatus(String transactionId, String newStatus) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final statusEnum = newStatus == 'accepted' 
          ? TradeOfferStatus.accepted 
          : (newStatus == 'rejected' ? TradeOfferStatus.declined : TradeOfferStatus.pending);
          
      await ref
          .read(tradeOfferRepositoryProvider)
          .updateOfferStatus(transactionId, statusEnum);

      final client = ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;
      
      final offers = await ref.read(tradeOfferRepositoryProvider).fetchOffersByUserId(user?.id ?? '');
      return offers.map((o) => ProductTransaction(
        id: o.id,
        productId: o.receiverProductId,
        productTitle: 'Intercambio de Artículo',
        sellerId: o.receiverId,
        sellerName: 'Vendedor',
        buyerId: o.senderId,
        buyerName: 'Comprador',
        price: o.additionalCash,
        status: o.status == TradeOfferStatus.accepted 
            ? TransactionStatus.accepted 
            : (o.status == TradeOfferStatus.declined ? TransactionStatus.cancelled : TransactionStatus.pending),
        createdAt: o.createdAt,
        updatedAt: o.createdAt,
      )).toList();
    });
  }

  Future<void> procesarCambioEstadoTrueque({
    required String transactionId,
    required String productId,
    required TransactionStatus nuevoEstado,
  }) async {
    await changeStatus(transactionId, nuevoEstado.name);
  }
}
