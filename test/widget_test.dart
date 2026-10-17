import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:trueke/app/app.dart';
import 'package:trueke/core/services/notifications/notification_service.dart';
import 'package:trueke/core/services/notifications/providers/push_notifications_provider.dart';
import 'package:trueke/core/services/notifications/repositories/notification_tokens_repository.dart';

// Implementación Mock idéntica al contrato abstracto de NotificationService
class MockNotificationTokensRepository implements NotificationTokensRepository {
  @override
  Future<void> saveToken({
    required String userId,
    required String token,
  }) async {}

  @override
  Future<void> deleteToken({required String token}) async {}
}

class MockNotificationService implements NotificationService {
  @override
  Future<bool> requestPermissions() async => false;

  @override
  Future<String?> getDeviceToken() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream<String>.empty();

  @override
  Stream<Map<String, dynamic>> get notificationStream =>
      const Stream<Map<String, dynamic>>.empty();

  @override
  List<StreamSubscription<RemoteMessage>> initializeMessageListeners(
    void Function(RemoteMessage message) onMessageReceived,
  ) => [];
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Evita que el test construya FirebaseNotificationService/FirebaseMessaging.
          appNotificationServiceProvider.overrideWith(
            (ref) => MockNotificationService(),
          ),
          notificationServiceProvider.overrideWith(
            (ref) => MockNotificationService(),
          ),
          notificationTokensRepositoryProvider.overrideWith(
            (ref) => MockNotificationTokensRepository(),
          ),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(MyApp), findsOneWidget);
  });
}
