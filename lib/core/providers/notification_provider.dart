import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/core/services/notifications/providers/push_notifications_provider.dart';

/// Proveedor global de eventos de datos recibidos mediante FCM.
///
/// La instancia utilizada es la misma familia de servicio FCM que gestiona
/// permisos, tokens y listeners. No depende del antiguo singleton eliminado.
final truekeNotificationProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.notificationStream;
});
