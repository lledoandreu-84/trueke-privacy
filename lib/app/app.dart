import 'package:trueke/features/splash/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/features/auth/auth_page.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/features/products/product_detail_page.dart';
import 'package:trueke/core/services/notifications/notification_service.dart';
import 'package:trueke/core/services/notifications/providers/push_notifications_provider.dart';
import 'package:trueke/app/shell/main_shell.dart';
import 'package:trueke/features/chat/presentation/screens/chat_screen.dart';
import 'package:trueke/core/theme/app_theme.dart';

final appNotificationServiceProvider = Provider<NotificationService>((ref) {
  return ref.watch(notificationServiceProvider);
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _showSplash = true;
  List<StreamSubscription> _notificationSubs = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final service = ref.read(appNotificationServiceProvider);
        service.requestPermissions().then((authorized) {
          if (authorized) {
            _notificationSubs = service.initializeMessageListeners((message) {
              // Manejo de notificaciones
            });
          }
        });
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    for (var sub in _notificationSubs) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trueke',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: _showSplash ? const SplashPage() : StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            return const MainShell();
          }
          return const AuthPage();
        },
      ),
      onGenerateRoute: (settings) {
        if (settings.name == 'product' || settings.name == '/product') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
            settings: settings,
          );
        }
        if (settings.name == 'chat' || settings.name == '/chat') {
          final args = settings.arguments;
          final roomId = args is String ? args : (args is Map ? args['roomId'] as String? : null);
          return MaterialPageRoute(
            builder: (_) => ChatScreen(roomId: roomId ?? ''),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
