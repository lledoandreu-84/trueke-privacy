import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/core/theme/app_colors.dart';
import 'package:trueke/features/chat/presentation/screens/chat_screen.dart';
import 'package:trueke/features/chat/providers/chat_providers.dart';
import 'package:trueke/features/products/presentation/screens/product_search_screen.dart';
import 'package:trueke/shared/widgets/custom_app_bar.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final chatRoomsAsync = ref.watch(
      userChatRoomsStreamProvider(currentUserId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(titleText: 'Mensajes'),
      body: chatRoomsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) =>
            Center(child: Text('Error al cargar los chats: $err')),
        data: (rooms) {
          if (rooms.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
            itemBuilder: (context, index) {
              final room = rooms[index];
              final productAsync = ref.watch(
                chatProductProvider(room.productId),
              );

              return productAsync.when(
                data: (product) {
                  if (product == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      // Forzamos el borrado directo en Supabase
                      await Supabase.instance.client
                          .from('conversations')
                          .delete()
                          .eq('id', room.id);

                      ref.invalidate(
                        userChatRoomsStreamProvider(currentUserId),
                      );
                    });
                    return const SizedBox.shrink();
                  }

                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.surfaceMint,
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      product.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text('Toca para chatear'),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                      onPressed: () async {
                        final confirm = await _showDeleteDialog(context);
                        if (confirm == true) {
                          await ref
                              .read(chatRepositoryProvider)
                              .deleteConversation(room.id);
                          ref.invalidate(
                            userChatRoomsStreamProvider(currentUserId),
                          );
                        }
                      },
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(roomId: room.id),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar conversación'),
        content: const Text('¿Estás seguro de que deseas eliminar este chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 40,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No tienes conversaciones activas',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductSearchScreen(),
              ),
            ),
            icon: const Icon(Icons.search_rounded),
            label: const Text('Explorar productos'),
          ),
        ],
      ),
    );
  }
}
