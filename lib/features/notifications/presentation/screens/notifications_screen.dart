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
      appBar: AppBar(
        title: Text('Notificaciones', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: truekesAsync.when(
        data: (truekes) {
          final notificationData = notificationsAsync.value ?? {};
          final hasNotifications = notificationData.isNotEmpty;

          if (truekes.isEmpty && !hasNotifications) {
            return Center(child: Text('Tu bandeja de entrada está vacía', style: theme.textTheme.bodyMedium));
          }

          return ListView.builder(
            itemCount: truekes.length + (hasNotifications ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < truekes.length) {
                final trueke = truekes[index];
                final myProduct = trueke['myProduct']!;
                final otherProduct = trueke['truekeProduct']!;
                
                return ListTile(
                  leading: const Icon(Icons.swap_horiz, color: Colors.green),
                  title: Text('Trueke: ${myProduct.title} por ${otherProduct.title}'),
                  subtitle: const Text('Toca para chatear con el propietario.'),
                  onTap: () async {
                    final chatRepo = ref.read(chatRepositoryProvider);
                    final chatRoom = await chatRepo.getOrCreateConversation(sellerId: otherProduct.ownerId, productId: otherProduct.id);
                    if (context.mounted) Navigator.of(context).pushNamed('/chat', arguments: chatRoom.id);
                  },
                );
              } else {
                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(notificationData['title']?.toString() ?? 'Notificación'),
                  subtitle: Text(notificationData['message']?.toString() ?? ''),
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
