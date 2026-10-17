import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/auth_service.dart';
import '../../../supabase/supabase_client.dart';
import '../notification_service.dart';
import '../repositories/notification_tokens_repository.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return FirebaseNotificationService();
});

final notificationTokensRepositoryProvider =
    Provider<NotificationTokensRepository>((ref) {
      final client = ref.watch(supabaseClientProvider);
      return SupabaseNotificationTokensRepository(client);
    });

final pushNotificationsSyncProvider = Provider.autoDispose<void>((ref) {
  final userAsync = ref.watch(authUserIdProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final tokensRepository = ref.watch(notificationTokensRepositoryProvider);

  userAsync.whenData((userId) async {
    if (userId != null) {
      // 1. El usuario está autenticado: Solicitar permisos nativos
      final hasPermission = await notificationService.requestPermissions();
      if (!hasPermission) return;

      // 2. Capturar el token actual e impactarlo en Supabase
      final token = await notificationService.getDeviceToken();
      if (token != null) {
        await tokensRepository.saveToken(userId: userId, token: token);
      }

      // 3. Escuchar reactivamente si el token se refresca en segundo plano
      final subscription = notificationService.onTokenRefresh.listen((
        newToken,
      ) async {
        await tokensRepository.saveToken(userId: userId, token: newToken);
      });
      ref.onDispose(subscription.cancel);
    } else {
      // 4. El usuario ha cerrado sesión: Intentar recuperar el token para darlo de baja
      final token = await notificationService.getDeviceToken();
      if (token != null) {
        await tokensRepository.deleteToken(token: token);
      }
    }
  });
});
