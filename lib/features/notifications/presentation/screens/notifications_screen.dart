import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notifications/providers/notifications_history_provider.dart';
import '../managers/in_app_notification_manager.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Notificaciones',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          notificationsAsync.maybeWhen(
            data: (list) => list.any((n) => !n.isRead)
                ? IconButton(
                    icon: Icon(
                      Icons.done_all_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: 'Marcar todo como leído',
                    onPressed: () {
                      ref
                          .read(notificationsHistoryProvider.notifier)
                          .markAllAsRead();
                      ref
                          .read(unreadNotificationsCountProvider.notifier)
                          .reset();
                    },
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 54,
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tu bandeja de entrada está vacía',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(180),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator.adaptive(
            onRefresh: () => ref.refresh(notificationsHistoryProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isUnread = !notification.isRead;

                return Container(
                  color: isUnread
                      ? theme.colorScheme.primaryContainer.withAlpha(25)
                      : Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isUnread
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        _getIconForType(notification.type),
                        color: isUnread
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isUnread
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        notification.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    trailing: isUnread
                        ? IconButton(
                            icon: Icon(
                              Icons.circle,
                              color: theme.colorScheme.primary,
                              size: 10,
                            ),
                            onPressed: () {
                              ref
                                  .read(notificationsHistoryProvider.notifier)
                                  .markAsRead(notification.id);
                              ref
                                  .read(
                                    unreadNotificationsCountProvider.notifier,
                                  )
                                  .decrement();
                            },
                          )
                        : null,
                    onTap: () {
                      if (isUnread) {
                        ref
                            .read(notificationsHistoryProvider.notifier)
                            .markAsRead(notification.id);
                        ref
                            .read(unreadNotificationsCountProvider.notifier)
                            .decrement();
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error al cargar notificaciones: $error',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      case 'exchange':
        return Icons.swap_horizontal_circle_outlined;
      case 'system':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }
}
