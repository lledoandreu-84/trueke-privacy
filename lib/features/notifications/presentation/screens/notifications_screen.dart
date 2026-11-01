import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/providers/trueke_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../chat/providers/chat_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final truekesAsync = ref.watch(truekeProvider);
    final notificationsAsync = ref.watch(truekeNotificationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: Column(
        children: [
          truekesAsync.when(
            data: (truekes) {
              if (truekes.isEmpty) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.primary, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¡Hay Truekes disponibles!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Tienes ${truekes.length} coincidencia(s) perfecta(s) esperando.'),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          Expanded(
            child: truekesAsync.when(
              data: (truekes) {
                final notificationData = notificationsAsync.value ?? {};
                final hasNotifications = notificationData.isNotEmpty;

                if (truekes.isEmpty && !hasNotifications) {
                  return Center(
                    child: Text('Tu bandeja de entrada está vacía', style: theme.textTheme.bodyMedium),
                  );
                }

                return ListView(
                  children: [
                    ...truekes.map((trueke) {
                      final myProduct = trueke['myProduct']!;
                      final otherProduct = trueke['truekeProduct']!;
                      
                      return ListTile(
                        leading: const Icon(Icons.swap_horiz, color: Colors.green),
                        title: Text('Trueke: ${myProduct.title} por ${otherProduct.title}'),
                        subtitle: const Text('Toca para chatear con el propietario.'),
                        onTap: () async {
                          try {
                            // Obtenemos o creamos la sala de chat usando el repositorio
                            final chatRepo = ref.read(chatRepositoryProvider);
                            final chatRoom = await chatRepo.getOrCreateConversation(
                              sellerId: otherProduct.ownerId,
                              productId: otherProduct.id,
                            );
                            
                            if (context.mounted) {
                              Navigator.of(context).pushNamed('/chat', arguments: chatRoom.id);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al abrir el chat: $e')),
                              );
                            }
                          }
                        },
                      );
                    }),
                    if (hasNotifications)
                      ListTile(
                        title: Text(notificationData['title']?.toString() ?? 'Notificación'),
                        subtitle: Text(notificationData['message']?.toString() ?? ''),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator.adaptive()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
