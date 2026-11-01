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
    
    final hasTruekes = truekesAsync.when(data: (t) => t.isNotEmpty, loading: () => false, error: (_, _) => false);
    final hasNotifications = notificationsAsync.when(data: (n) => n.isNotEmpty, loading: () => false, error: (_, _) => false);
    final showBadge = hasTruekes || hasNotifications;

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
                  icon: Icon(showBadge ? Icons.notifications_rounded : Icons.notifications_none_rounded, color: AppColors.petrolBlue, size: 23),
                  onPressed: () => Navigator.of(context).pushNamed('/notifications'),
                ),
                if (showBadge)
                  Positioned(right: 8, top: 8, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
