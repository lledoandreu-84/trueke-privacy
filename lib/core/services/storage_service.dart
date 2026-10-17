import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio unificado y centralizado para la gestión de archivos e imágenes
/// en Supabase Storage (productos y avatares de perfil).
class StorageService {
  StorageService({
    SupabaseClient? client,
    this.mockUploadInterceptor,
    this.mockRemoveInterceptor,
  }) : _customClient = client;

  final Future<String> Function(String path, File file)? mockUploadInterceptor;
  final Future<void> Function(List<String> paths)? mockRemoveInterceptor;

  final SupabaseClient? _customClient;
  SupabaseClient get _supabase => _customClient ?? Supabase.instance.client;

  static const String _productBucket = 'product-images';
  static const String _productPublicPath =
      '/storage/v1/object/public/$_productBucket/';

  static const String _avatarBucket = 'avatars';
  static const String _avatarPublicPath =
      '/storage/v1/object/public/$_avatarBucket/';

  /// Sube la imagen de un producto al bucket 'product-images' organizado por userId.
  Future<String> uploadProductImage(File imageFile) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('Debes iniciar sesión para subir imágenes.');
    }

    final extension = _extensionFromPath(imageFile.path);
    final fileName = '${DateTime.now().microsecondsSinceEpoch}.$extension';
    final path = '${user.id}/$fileName';

    if (mockUploadInterceptor != null) {
      return await mockUploadInterceptor!(path, imageFile);
    }

    await _supabase.storage
        .from(_productBucket)
        .upload(
          path,
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    return _supabase.storage.from(_productBucket).getPublicUrl(path);
  }

  /// Elimina una imagen de producto de Supabase Storage tras validar propiedad.
  Future<void> deleteProductImage(String publicUrl) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('Debes iniciar sesión para eliminar imágenes.');
    }

    final markerIndex = publicUrl.indexOf(_productPublicPath);

    if (markerIndex == -1) {
      throw ArgumentError(
        'La URL no pertenece al bucket de imágenes de productos.',
      );
    }

    final path = publicUrl.substring(markerIndex + _productPublicPath.length);

    if (path.isEmpty || !path.startsWith('${user.id}/')) {
      throw const AuthException(
        'No puedes eliminar una imagen que no pertenece a tu usuario.',
      );
    }

    if (mockRemoveInterceptor != null) {
      await mockRemoveInterceptor!([path]);
      return;
    }

    await _supabase.storage.from(_productBucket).remove([path]);
  }

  /// Sube o actualiza el avatar del usuario en el bucket 'avatars'.
  Future<String> uploadAvatar({
    required File file,
    required String userId,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException('Debes iniciar sesión para subir un avatar.');
    }

    if (user.id != userId) {
      throw const AuthException(
        'No tienes permiso para actualizar el avatar de otro usuario.',
      );
    }

    final extension = _extensionFromPath(file.path);
    final path = '$userId/avatar.$extension';

    await _supabase.storage
        .from(_avatarBucket)
        .upload(
          path,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

    return _supabase.storage.from(_avatarBucket).getPublicUrl(path);
  }

  /// Elimina el avatar del usuario si fuera necesario.
  Future<void> deleteAvatar(String publicUrl) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'Debes iniciar sesión para eliminar un avatar.',
      );
    }

    final markerIndex = publicUrl.indexOf(_avatarPublicPath);

    if (markerIndex == -1) {
      return;
    }

    final path = publicUrl.substring(markerIndex + _avatarPublicPath.length);

    if (path.isNotEmpty && path.startsWith('${user.id}/')) {
      await _supabase.storage.from(_avatarBucket).remove([path]);
    }
  }

  String _extensionFromPath(String path) {
    final dotIndex = path.lastIndexOf('.');

    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return 'jpg';
    }

    final extension = path.substring(dotIndex + 1).toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
        return extension == 'jpeg' ? 'jpg' : extension;
      default:
        return 'jpg';
    }
  }
}
