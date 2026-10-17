import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Funcion global obligatoria Top-Level para la intercepcion de mensajes con la app cerrada.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}

abstract class NotificationService {
  Future<bool> requestPermissions();
  Future<String?> getDeviceToken();
  Stream<String> get onTokenRefresh;
  Stream<Map<String, dynamic>> get notificationStream;

  List<StreamSubscription<RemoteMessage>> initializeMessageListeners(
    void Function(RemoteMessage message) onMessageReceived,
  );
}

class FirebaseNotificationService implements NotificationService {
  FirebaseNotificationService([FirebaseMessaging? messaging])
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  final StreamController<Map<String, dynamic>> _notificationStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  bool _backgroundHandlerRegistered = false;

  @override
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStreamController.stream;

  @override
  Future<bool> requestPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> getDeviceToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  List<StreamSubscription<RemoteMessage>> initializeMessageListeners(
    void Function(RemoteMessage message) onMessageReceived,
  ) {
    final List<StreamSubscription<RemoteMessage>> subscriptions = [];

    if (!_backgroundHandlerRegistered) {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      _backgroundHandlerRegistered = true;
    }

    final foregroundSub = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
      if (message.data.isNotEmpty) {
        _notificationStreamController.add(message.data);
      }

      if (message.notification != null) {
        onMessageReceived(message);
      }
    });

    subscriptions.add(foregroundSub);

    final backgroundSub = FirebaseMessaging.onMessageOpenedApp.listen((
      RemoteMessage message,
    ) {
      if (message.data.isNotEmpty) {
        _notificationStreamController.add(message.data);
      }
    });

    subscriptions.add(backgroundSub);

    return subscriptions;
  }

  void dispose() {
    _notificationStreamController.close();
  }
}
