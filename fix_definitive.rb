require 'fileutils'

# 1. Restaurar contador numérico en HomeHeader
header_content = <<~DART
import 'package:trueke/core/providers/notification_provider.dart';
import 'package:trueke/features/products/providers/trueke_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(truekeNotificationProvider);
    final truekesAsync = ref.watch(truekeProvider);
    
    final truekesCount = truekesAsync.when(data: (t) => t.length, loading: () => 0, error: (_, _) => 0);
    final notifCount = notificationsAsync.when(data: (n) => n.length, loading: () => 0, error: (_, _) => 0);
    final totalCount = truekesCount + notifCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Row(
        children: [
          Image.asset('assets/images/logo.png', width: 40, height: 40, fit: BoxFit.contain),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Trueke', style: TextStyle(fontFamily: 'Montserrat', fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
                SizedBox(height: 4),
                Text('Intercambia. Descubre. Reutiliza.', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(color: AppColors.surfaceMint, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border, width: 1)),
            child: Stack(
              children: [
                IconButton(
                  tooltip: 'Conversaciones y Notificaciones',
                  icon: Icon(totalCount > 0 ? Icons.notifications_rounded : Icons.notifications_none_rounded, color: AppColors.petrolBlue, size: 23),
                  onPressed: () => Navigator.of(context).pushNamed('/notifications'),
                ),
                if (totalCount > 0)
                  Positioned(
                    right: 8, top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text('$totalCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
DART
File.write('lib/features/home/widgets/home_header.dart', header_content)

# 2. Corregir Pantalla de Notificaciones (Logo, Estilo y Filtro de usuario)
screen_content = <<~DART
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/providers/trueke_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../chat/providers/chat_providers.dart';
import '../../../../core/theme/app_text_styles.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final truekesAsync = ref.watch(truekeProvider);
    final notificationsAsync = ref.watch(truekeNotificationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
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
                  leading: Image.asset('assets/images/logo.png', width: 24, height: 24),
                  title: Text('Trueke: \${myProduct.title} por \${otherProduct.title}'),
                  subtitle: const Text('Toca para chatear con el propietario.'),
                  onTap: () async {
                    try {
                      final chatRepo = ref.read(chatRepositoryProvider);
                      final chatRoom = await chatRepo.getOrCreateConversation(sellerId: otherProduct.ownerId, productId: otherProduct.id);
                      if (context.mounted) Navigator.of(context).pushNamed('/chat', arguments: chatRoom.id);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \${e.toString()}')));
                      }
                    }
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
        error: (e, _) => Center(child: Text('Error: \$e')),
      ),
    );
  }
}
DART
File.write('lib/features/notifications/presentation/screens/notifications_screen.dart', screen_content)
