import '../../../chat/presentation/screens/chat_screen.dart';
import '../../../chat/data/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:trueke/shared/widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/providers/trueke_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(truekeMatchesProvider);

    return Scaffold(
      appBar: const CustomAppBar(titleText: 'Notificaciones'),
      body: matchesAsync.when(
        data: (matches) {
          if (matches.isEmpty) {
            return const Center(child: Text('No hay notificaciones nuevas'));
          }
          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              final matchId = match['matchId'] as String;
              
final isRead = match['isRead'] ?? false;
              return ListTile(
                onTap: () async {
                  final chatRepo = SupabaseChatRepository(null);
                  final room = await chatRepo.getOrCreateConversation(
                    productId: match['truekeProduct'].id,
                    sellerId: match['truekeProduct'].ownerId,
                  );
                  if (context.mounted) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(roomId: room.id)));
                  }
                },
                leading: Stack(
                  children: [
                    Image.asset('assets/images/logo.png', width: 24, height: 24),
                    if (!isRead) Positioned(right: 0, top: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
                  ],
                ),
                title: Text('Trueke: ${match['myProduct'].title} por ${match['truekeProduct'].title}'),
                subtitle: const Text('Toca para chatear con el propietario.'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Eliminar coincidencia'),
                        content: const Text('¿Estás seguro de que deseas ocultar esta coincidencia?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(ctx).pop();
                              await ref.read(hiddenTruekesProvider.notifier).hide(matchId);
                            },
                            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
