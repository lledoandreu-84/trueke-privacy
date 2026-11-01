import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/providers/trueke_provider.dart';
import '../../../../core/providers/notification_provider.dart';

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
          // Banner de Truekes
          truekesAsync.when(
            data: (truekes) {
              if (truekes.isEmpty) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
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

          // Lista de Notificaciones normales
          Expanded(
            child: notificationsAsync.when(
              data: (notificationData) {
                if (notificationData.isEmpty) {
                  return Center(
                    child: Text('Tu bandeja de entrada está vacía', style: theme.textTheme.bodyMedium),
                  );
                }
                return ListView(
                  children: [
                    ListTile(
                      title: Text(notificationData['title']?.toString() ?? 'Notificación'),
                      subtitle: Text(notificationData['message']?.toString() ?? ''),
                    ),
                  ],
                );
              },
              // Si está cargando pero ya tenemos el banner, mostramos vacío tras un instante
              loading: () => Center(
                child: Text('Tu bandeja de entrada está vacía', style: theme.textTheme.bodyMedium),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
