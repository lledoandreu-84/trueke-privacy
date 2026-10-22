import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/products/repositories/product_repository.dart';

export 'package:trueke/features/products/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});
