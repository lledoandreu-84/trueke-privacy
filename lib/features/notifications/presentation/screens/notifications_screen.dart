import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/providers/trueke_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(truekeMatchesProvider);

    return Scaffold(
      appBar: AppBar(
  title: const Text('Notificaciones'),
  centerTitle: true,
  elevation: 0,
),
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
              
              return ListTile(
                leading: Image.asset('assets/images/logo.png', width: 24, height: 24),
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
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              final notifier = ref.read(hiddenTruekesProvider);
                              notifier.value = [...notifier.value, matchId];
                              final _ = ref.refresh(truekeMatchesProvider);
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
