import 'package:trueke/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/core/theme/app_colors.dart';
import 'package:trueke/features/chat/providers/chat_providers.dart';
import 'package:trueke/features/chat/presentation/screens/chat_screen.dart';
import 'package:trueke/features/products/presentation/screens/product_search_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final chatRoomsAsync = ref.watch(userChatRoomsStreamProvider(currentUserId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(titleText: 'Mensajes'),
      body: chatRoomsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error al cargar los chats: $err',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
        data: (rooms) {
          if (rooms.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceMint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No tienes conversaciones activas',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Los chats de tus negociaciones e intercambios aparecerán aquí en tiempo real.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Navegamos directamente a la pantalla de Explorar (ProductSearchScreen)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductSearchScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: const Text(
                        'Explorar productos',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return Material(
                color: Colors.transparent,
                child: ListTile(
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Eliminar conversación'),
                              content: const Text('¿Estás seguro de que deseas eliminar este chat? Esta acción no se puede deshacer.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirm == true) {
                          try {
                            await ref.read(chatRepositoryProvider).deleteConversation(room.id);
                            ref.invalidate(userConversationsProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Conversación eliminada correctamente')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al eliminar: $e')),
                              );
                            }
                          }
                        }
                      },
                    ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(roomId: room.id),
                      ),
                    );
                  },
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceMint,
                    child: Icon(Icons.person_rounded, color: AppColors.primary),
                  ),
                  title: Consumer(
            builder: (context, ref, child) {
              final productAsync = ref.watch(chatProductProvider(room.productId));
              
              final productTitle = productAsync.when(
                data: (product) => product?.title ?? 'Negociación de Artículo',
                loading: () => 'Cargando...',
                error: (_, _) => 'Negociación de Artículo',
              );

              return Text(
                productTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              );
            },
          ),
                  subtitle: const Text(
                    'Chat activo de Trueke',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
