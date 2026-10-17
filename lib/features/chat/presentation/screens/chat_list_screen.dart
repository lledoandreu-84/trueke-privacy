import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../../profile/providers/profile_provider.dart';
import 'package:trueke/features/chat/providers/chat_providers.dart';
import 'chat_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(supabaseClientProvider);
    final currentUserId = client.auth.currentUser?.id;
    final theme = Theme.of(context);

    if (currentUserId == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Center(
          child: Text(
            'Usuario no autenticado',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final chatRoomsAsync = ref.watch(
      userChatRoomsStreamProvider(currentUserId),
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Mensajes',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: chatRoomsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, _) =>
            Center(child: Text('Error al cargar mensajes: $err')),
        data: (rooms) {
          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes conversaciones activas',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.5,
              color: theme.colorScheme.outlineVariant,
              indent: 80,
            ),
            itemBuilder: (context, index) {
              final room = rooms[index];
              final isBuyer = room.buyerId == currentUserId;
              final peerId = isBuyer ? room.sellerId : room.buyerId;

              final peerProfileAsync = ref.watch(userProfileProvider(peerId));
              final productAsync = ref.watch(
                chatProductProvider(room.productId),
              );

              void navigateToChat(BuildContext ctx) {
                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(roomId: room.id),
                  ),
                );
              }

              return productAsync.when(
                loading: () => const ListTile(title: Text('Cargando chat...')),
                error: (err, _) => ListTile(
                  title: const Text('Conversación'),
                  subtitle: Text('Error: $err'),
                  onTap: () => navigateToChat(context),
                ),
                data: (product) {
                  if (product == null) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      title: Text(
                        'Trueque no disponible',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'El artículo ya no existe o fue eliminado',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: theme.colorScheme.outline,
                      ),
                      onTap: () => navigateToChat(context),
                    );
                  }

                  final hasImage =
                      product.images.isNotEmpty &&
                      product.images.first.isNotEmpty;
                  final productImg = hasImage ? product.images.first : '';

                  return peerProfileAsync.when(
                    data: (profile) {
                      final peerName = profile.displayName;
                      final messagesAsync = ref.watch(
                        chatMessagesStreamProvider(room.id),
                      );

                      final subtitleText = messagesAsync.maybeWhen(
                        data: (messages) {
                          dynamic lastOfferPayload;
                          for (final msg in messages.reversed) {
                            if (msg.message.startsWith("[TRADE_OFFER]:")) {
                              try {
                                final jsonStr = msg.message.substring(
                                  "[TRADE_OFFER]:".length,
                                );
                                lastOfferPayload = jsonDecode(jsonStr);
                                break;
                              } catch (_) {}
                            }
                          }

                          if (lastOfferPayload != null) {
                            final status =
                                lastOfferPayload["status"] ?? "pending";
                            if (status == "pending") {
                              return "🔸 Propuesta pendiente de trueque";
                            }
                            if (status == "accepted") {
                              return "💚 ¡Trueke Aceptado! En proceso";
                            }
                            if (status == "completed") {
                              return "🤝 Trato finalizado con éxito";
                            }
                            if (status == "cancelled") {
                              return "❌ Propuesta de trueque rechazada";
                            }
                          }
                          return 'Chat con $peerName';
                        },
                        orElse: () => 'Chat con $peerName',
                      );

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 48,
                            height: 48,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: productImg.isNotEmpty
                                ? Image.network(
                                    productImg,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => const Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 18,
                                        ),
                                  )
                                : const Icon(Icons.image_outlined, size: 18),
                          ),
                        ),
                        title: Text(
                          product.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          subtitleText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: subtitleText.startsWith('Chat con')
                                ? FontWeight.normal
                                : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: theme.colorScheme.outline,
                        ),
                        onTap: () => navigateToChat(context),
                      );
                    },
                    loading: () =>
                        const ListTile(title: Text('Cargando perfil...')),
                    error: (err, _) => ListTile(
                      title: Text(product.title),
                      subtitle: const Text('Error al cargar interlocutor'),
                      onTap: () => navigateToChat(context),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
