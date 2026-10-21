import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/product.dart';
import 'product_repository_provider.dart';
import 'products_provider.dart';
import 'paginated_products_provider.dart';

class PublishProductState {
  final bool isPublishing;
  final bool isSuccess;
  final String? errorMessage;
  final List<File> selectedImages;

  PublishProductState({
    this.isPublishing = false,
    this.isSuccess = false,
    this.errorMessage,
    this.selectedImages = const [],
  });

  PublishProductState copyWith({
    bool? isPublishing,
    bool? isSuccess,
    String? errorMessage,
    List<File>? selectedImages,
  }) {
    return PublishProductState(
      isPublishing: isPublishing ?? this.isPublishing,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      selectedImages: selectedImages ?? this.selectedImages,
    );
  }
}

class PublishProductNotifier extends Notifier<PublishProductState> {
  @override
  PublishProductState build() => PublishProductState();

  void setImages(List<File> files) {
    state = state.copyWith(selectedImages: files);
  }

  void clearImages() {
    state = PublishProductState();
  }

  static const List<String> _blacklist = [
    'arma',
    'pistola',
    'escopeta',
    'droga',
    'cocaina',
    'marihuana',
    'falsificado',
    'replica',
    'fake',
    'insulto',
    'estafa',
  ];

  void _validateContent(String title, String description) {
    final textToCheck = '$title $description'.toLowerCase();
    for (final word in _blacklist) {
      if (textToCheck.contains(word)) {
        throw Exception(
          'El contenido infringe las normas de Trueke (Término no permitido: $word).',
        );
      }
    }
  }

  Future<void> submitProduct({
    required String title,
    required String description,
    required double? price,
    required String category,
    required String owner,
    required String ownerId,
    required String condition,
    required TradeType tradeType,
    required String wanted,
    required String location,
    required double? latitude,
    required double? longitude,
  }) async {
    state = state.copyWith(isPublishing: true, errorMessage: null);

    try {
      _validateContent(title, description);

      final productRepo = ref.read(productRepositoryProvider);
      final List<String> uploadedUrls = [];

      for (final file in state.selectedImages) {
        final xFile = XFile(file.path);
        final bytes = await xFile.readAsBytes();
        final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}_${uploadedUrls.length}.jpg';
        
        // Sube directo al bucket de Supabase usando el repositorio de productos
        final imageUrl = await productRepo.uploadProductImage(bytes, fileName);
        if (imageUrl.isNotEmpty) {
          uploadedUrls.add(imageUrl);
        }
      }

      final newProduct = Product(
        id: '',
        title: title,
        description: description,
        price: price,
        images: uploadedUrls,
        category: category,
        owner: owner,
        ownerId: ownerId,
        condition: condition,
        tradeType: tradeType,
        wanted: wanted,
        location: location,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now(),
      );

      await productRepo.createProduct(newProduct);

      ref.invalidate(paginatedProductsProvider);
      ref.invalidate(productsProvider);

      state = state.copyWith(isPublishing: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isPublishing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        selectedImages: state.selectedImages,
      );
    }
  }

  Future<void> updateExistingProduct({
    required String productId,
    required String title,
    required String description,
    required double? price,
    required String category,
    required String owner,
    required String ownerId,
    required String condition,
    required TradeType tradeType,
    required String wanted,
    required String location,
    required double? latitude,
    required double? longitude,
    required List<String> existingImages,
    required DateTime createdAt,
  }) async {
    state = state.copyWith(isPublishing: true, errorMessage: null);

    try {
      _validateContent(title, description);

      final productRepo = ref.read(productRepositoryProvider);
      final List<String> finalImages = List.from(existingImages);

      for (final file in state.selectedImages) {
        final xFile = XFile(file.path);
        final bytes = await xFile.readAsBytes();
        final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}_${finalImages.length}.jpg';
        
        final imageUrl = await productRepo.uploadProductImage(bytes, fileName);
        if (imageUrl.isNotEmpty) {
          finalImages.add(imageUrl);
        }
      }

      final updatedProduct = Product(
        id: productId,
        title: title,
        description: description,
        price: price,
        images: finalImages,
        category: category,
        owner: owner,
        ownerId: ownerId,
        condition: condition,
        tradeType: tradeType,
        wanted: wanted,
        location: location,
        latitude: latitude,
        longitude: longitude,
        createdAt: createdAt,
      );

      await productRepo.updateProduct(updatedProduct);

      ref.invalidate(paginatedProductsProvider);
      ref.invalidate(productsProvider);

      state = state.copyWith(isPublishing: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isPublishing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        selectedImages: state.selectedImages,
      );
    }
  }
}

final publishProductProvider =
    NotifierProvider<PublishProductNotifier, PublishProductState>(
      () => PublishProductNotifier(),
    );

final publishProductNotifierProvider = publishProductProvider;
