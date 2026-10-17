import 'dart:io';
import '../../../../models/product.dart';

abstract class PublishProductRepository {
  /// Sube una imagen al Storage de Supabase y devuelve su URL pública.
  Future<String> uploadProductImage(File imageFile, String userId);

  /// Registra un nuevo producto en la base de datos de Supabase.
  Future<void> publishProduct(Product product);
}
