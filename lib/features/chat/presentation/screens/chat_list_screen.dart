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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Usuario no autenticado',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: chatRoomsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error al cargar mensajes: $err',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
        data: (rooms) {
          if (rooms.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 56,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No tienes conversaciones activas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Los chats de tus negociaciones aparecerán aquí.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: rooms.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
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
                loading: () => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Center(child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
                ),
                error: (err, _) => Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: const Text('Conversación'),
                    subtitle: Text('Error: $err'),
                    onTap: () => navigateToChat(context),
                  ),
                ),
                data: (product) {
                  if (product == null) {
                    return Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 24,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        title: Text(
                          'Trueque no disponible',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'El artículo ya no existe o fue eliminado',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        onTap: () => navigateToChat(context),
                      ),
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

                      return Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => navigateToChat(context),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        width: 56,
                                        height: 56,
                                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                        child: productImg.isNotEmpty
                                            ? Image.network(
                                                productImg,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    Icon(
                                                  Icons.image_not_supported_outlined,
                                                  size: 22,
                                                  color: theme.colorScheme.outline,
                                                ),
                                              )
                                            : Icon(
                                                Icons.image_outlined,
                                                size: 22,
                                                color: theme.colorScheme.outline,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.title,
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            subtitleText,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                              fontWeight: subtitleText.startsWith('Chat con')
                                                  ? FontWeight.normal
                                                  : FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: theme.colorScheme.outline,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Center(child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
                    ),
                    error: (err, _) => Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(product.title),
                        subtitle: const Text('Error al cargar interlocutor'),
                        onTap: () => navigateToChat(context),
                      ),
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
