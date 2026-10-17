import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/product.dart';
import '../domain/repositories/publish_product_repository.dart';

class SupabasePublishProductRepository implements PublishProductRepository {
  final SupabaseClient _supabaseClient;

  SupabasePublishProductRepository(this._supabaseClient);

  @override
  Future<String> uploadProductImage(File imageFile, String userId) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final filePath = '$userId/$fileName';

    // Sube el archivo al bucket llamado 'product-images'
    await _supabaseClient.storage
        .from('product-images')
        .upload(filePath, imageFile);

    // Obtiene y retorna la URL pública del archivo subido
    final String publicUrl = _supabaseClient.storage
        .from('product-images')
        .getPublicUrl(filePath);

    return publicUrl;
  }

  @override
  Future<void> publishProduct(Product product) async {
    // Inserta los datos mapeados del modelo Product en la tabla 'products'
    await _supabaseClient.from('products').insert(product.toJson());
  }
}
