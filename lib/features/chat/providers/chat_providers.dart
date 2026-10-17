import '../models/chat_room.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../data/chat_repository.dart';
import '../data/supabase_chat_repository.dart';
import '../models/chat_message.dart';
import '../../products/providers/product_repository_provider.dart';
import '../../../models/product.dart';
import '../../transactions/providers/transaction_providers.dart'
    hide supabaseClientProvider;
import '../../../models/transaction.dart';

/// Proveedor del repositorio de chat
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseChatRepository(client);
});

/// Proveedor reactivo del flujo de mensajes de una sala en tiempo real (requiere roomId)
final chatMessagesStreamProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, roomId) {
      final repository = ref.watch(chatRepositoryProvider);
      return repository.streamMessages(roomId);
    });

final userChatRoomsStreamProvider =
    StreamProvider.family<List<ChatRoom>, String>((ref, userId) {
      final repository = ref.watch(chatRepositoryProvider);
      return repository.streamUserChatRooms(userId);
    });

/// Proveedor asíncrono para obtener un producto individual por su ID para el chat
final chatProductProvider = FutureProvider.family<Product?, String>((
  ref,
  productId,
) async {
  final productRepo = ref.watch(productRepositoryProvider);
  return productRepo.getProductById(productId);
});

/// El proveedor cruza las transacciones del usuario en memoria para retornar el estado del trueque de este producto
final chatRoomTransactionStatusProvider =
    Provider.family<TransactionStatus?, String>((ref, productId) {
      final transactionsAsync = ref.watch(userTransactionsProvider);

      return transactionsAsync.maybeWhen(
        data: (transactions) {
          final match = transactions.firstWhere(
            (t) =>
                t.productId == productId &&
                t.status != TransactionStatus.cancelled,
            orElse: () => ProductTransaction(
              id: '',
              productId: '',
              productTitle: '',
              sellerId: '',
              sellerName: '',
              buyerId: '',
              buyerName: '',
              status: TransactionStatus.cancelled,
              createdAt: _dummyDate,
              updatedAt: _dummyDate,
            ),
          );
          if (match.id.isEmpty) {
            return null;
          }
          return match.status;
        },
        orElse: () => null,
      );
    });

/// Proveedor asíncrono para obtener una sala de chat individual por su ID
final singleChatRoomProvider = FutureProvider.family<ChatRoom?, String>((
  ref,
  roomId,
) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('chat_rooms')
      .select()
      .eq('id', roomId)
      .maybeSingle();
  if (response == null) return null;
  return ChatRoom.fromJson(response);
});

final _dummyDate = DateTime.fromMillisecondsSinceEpoch(0);
