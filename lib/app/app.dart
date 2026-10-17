import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/features/products/product_detail_page.dart';
import 'package:trueke/core/providers/shell_index_provider.dart';
import 'package:trueke/core/providers/notification_provider.dart';
import 'package:trueke/core/services/notifications/notification_service.dart';
import 'package:trueke/core/services/notifications/providers/push_notifications_provider.dart';
import 'package:trueke/app/shell/main_shell.dart';
import 'package:trueke/features/home/home_page.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/features/auth/auth_page.dart';
import 'package:trueke/features/chat/presentation/screens/chat_screen.dart';
import 'package:trueke/core/theme/app_theme.dart';
import 'package:trueke/features/home/widgets/trueke_logo_painter.dart';

final appNotificationServiceProvider = Provider<NotificationService>((ref) {
  return ref.watch(notificationServiceProvider);
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  List<StreamSubscription> _notificationSubs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final service = ref.read(appNotificationServiceProvider);
        service.requestPermissions().then((authorized) {
          if (authorized) {
            _notificationSubs = service.initializeMessageListeners((message) {
              if (message.notification != null && mounted) {
                final title = message.notification!.title ?? "Mensaje Nuevo";
                final body =
                    message.notification!.body ??
                    "Tienes un nuevo trueke esperando.";
                final roomId = message.data['roomId'] as String?;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          body,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.black87,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 4),
                    action: roomId != null
                        ? SnackBarAction(
                            label: "RESPONDER",
                            textColor: Colors.amber,
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                'chat',
                                arguments: roomId,
                              );
                            },
                          )
                        : null,
                  ),
                );
              }
            });
          }
        });
      } catch (e) {
        debugPrint(
          'Error al activar el servicio de notificaciones en Foreground: $e',
        );
      }
    });
  }

  @override
  void dispose() {
    for (final sub in _notificationSubs) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authStateAsync = ref.watch(authStateProvider);

    // Mantener activa la sincronización del token FCM con Supabase
    // mientras exista el árbol principal de la aplicación.
    ref.watch(pushNotificationsSyncProvider);

    ref.listen(truekeNotificationProvider, (previous, next) {
      next.whenData((payload) {
        if (payload.isNotEmpty && context.mounted) {
          final String? status = payload['status'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🔄 Trueke Actualizado: Estado cambiado a ${status ?? "desconocido"}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              action: SnackBarAction(
                label: 'Ver',
                textColor: Colors.white70,
                onPressed: () {
                  ref.read(shellIndexProvider.notifier).setIndex(3);
                },
              ),
            ),
          );
        }
      });
    });

    // Mapeo síncrono ultra robusto para la vista inicial evadiendo errores sintácticos de Riverpod
    Widget homeWidget;

    if (authStateAsync.isLoading) {
      homeWidget = Scaffold(
        backgroundColor: const Color(0xFFF0FDF4),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withAlpha(40),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CustomPaint(painter: TruekeLogoPainter()),
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
              ),
            ],
          ),
        ),
      );
    } else if (authStateAsync.hasError) {
      homeWidget = Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error de autenticación: ${authStateAsync.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
        ),
      );
    } else {
      final authState = authStateAsync.value;
      if (authState != null && authState.session != null) {
        homeWidget = const MainShell(child: HomePage());
      } else {
        homeWidget = const AuthPage();
      }
    }

    return MaterialApp(
      title: 'Trueke',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      onGenerateRoute: (settings) {
        final currentUser = ref.read(currentUserProvider);

        if (currentUser == null) {
          return MaterialPageRoute(
            builder: (_) => const AuthPage(),
            settings: settings,
          );
        }

        if (settings.name == 'product' || settings.name == '/product') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
            settings: settings,
          );
        }
        if (settings.name == 'chat' || settings.name == '/chat') {
          final args = settings.arguments;
          final roomId = args is String
              ? args
              : (args is Map ? args['roomId'] as String? ?? '' : '');
          return MaterialPageRoute(
            builder: (_) => ChatScreen(roomId: roomId),
            settings: settings,
          );
        }
        return null;
      },
      home: homeWidget,
    );
  }
}
