import '../../../../features/transactions/models/notification_model.dart';

abstract class NotificationsRepository {
  /// Obtiene el historial completo de notificaciones de un usuario específico de forma asíncrona.
  Future<List<NotificationModel>> fetchNotifications({required String userId});

  /// Marca una notificación concreta como leída.
  Future<void> markAsRead({required String notificationId});

  /// Marca todas las notificaciones pendientes de un usuario como leídas.
  Future<void> markAllAsRead({required String userId});
}
