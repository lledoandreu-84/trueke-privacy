import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase/supabase_client.dart';

class SupabaseRealtimeService {
  final SupabaseClient _client;
  RealtimeChannel? _messagesChannel;

  SupabaseRealtimeService(this._client);

  /// Inicializa la escucha activa en tiempo real para un usuario específico
  void subscribeToUserMessages({
    required String userId,
    required Function(PostgresChangePayload payload) onNewMessage,
  }) {
    // Si ya existe un canal activo de escucha, lo cancelamos para evitar duplicidades de hilos
    if (_messagesChannel != null) {
      _client.removeChannel(_messagesChannel!);
    }

    _messagesChannel = _client
        .channel('public:messages_user_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          // Filtramos dinámicamente para recibir solo eventos de inserción en caliente
          callback: (payload) {
            onNewMessage(payload);
          },
        );

    _messagesChannel?.subscribe();
  }

  /// Cierra de forma segura las conexiones y canales en caliente
  void dispose() {
    if (_messagesChannel != null) {
      _client.removeChannel(_messagesChannel!);
    }
  }
}

/// Proveedor global para inyectar el servicio de tiempo real distribuido
final realtimeServiceProvider = Provider.autoDispose<SupabaseRealtimeService>((
  ref,
) {
  final client = ref.watch(supabaseClientProvider);
  final service = SupabaseRealtimeService(client);

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
