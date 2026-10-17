import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueke/core/services/storage_service.dart';

class FakeUser extends Fake implements User {
  @override
  String get id => 'user_david_123';
}

class FakeGoTrueClient extends Fake implements GoTrueClient {
  bool hasUser = true;
  @override
  User? get currentUser => hasUser ? FakeUser() : null;
}

class FakeSupabaseClient extends Fake implements SupabaseClient {
  final authClient = FakeGoTrueClient();
  @override
  GoTrueClient get auth => authClient;
}

void main() {
  group('StorageService - Pruebas Unitarias de Logica y Seguridad', () {
    late FakeSupabaseClient fakeClient;
    late File testFile;

    setUp(() {
      fakeClient = FakeSupabaseClient();
      testFile = File('dummy_product_image.png');
    });

    test(
      'Debe fallar con AuthException si el usuario intenta subir un archivo sin sesion activa',
      () async {
        fakeClient.authClient.hasUser = false;
        final service = StorageService(client: fakeClient);
        expect(
          () => service.uploadProductImage(testFile),
          throwsA(isA<AuthException>()),
        );
      },
    );

    test(
      'Debe procesar adecuadamente la ruta bajo el id del usuario e invocar el interceptor al subir una imagen',
      () async {
        String? capturedPath;
        final service = StorageService(
          client: fakeClient,
          mockUploadInterceptor: (path, file) async {
            capturedPath = path;
            return 'https://supabase.co/storage/v1/object/public/product-images/user_david_123/mocked_image.png';
          },
        );
        final url = await service.uploadProductImage(testFile);
        expect(
          url,
          equals(
            'https://supabase.co/storage/v1/object/public/product-images/user_david_123/mocked_image.png',
          ),
        );
        expect(capturedPath, startsWith('user_david_123/'));
        expect(capturedPath, endsWith('.png'));
      },
    );

    test(
      'Debe arrojar ArgumentError si la URL a eliminar no coincide con el prefijo publico del bucket',
      () async {
        final service = StorageService(client: fakeClient);
        expect(
          () => service.deleteProductImage('https://supabase.co/invalid_path'),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test(
      'Debe arrojar AuthException si un usuario intenta borrar una imagen cuyo prefijo de ruta no le pertenece',
      () async {
        final service = StorageService(client: fakeClient);
        expect(
          () => service.deleteProductImage(
            'https://supabase.co/storage/v1/object/public/product-images/user_hacker_777/12345.png',
          ),
          throwsA(isA<AuthException>()),
        );
      },
    );

    test(
      'Debe invocar el interceptor de eliminacion si la URL es valida y pertenece al usuario logueado',
      () async {
        List<String>? capturedPaths;
        final service = StorageService(
          client: fakeClient,
          mockRemoveInterceptor: (paths) async {
            capturedPaths = paths;
          },
        );
        await service.deleteProductImage(
          'https://supabase.co/storage/v1/object/public/product-images/user_david_123/98765.png',
        );
        expect(capturedPaths, isNotNull);
        expect(capturedPaths!.first, equals('user_david_123/98765.png'));
      },
    );
  });
}
