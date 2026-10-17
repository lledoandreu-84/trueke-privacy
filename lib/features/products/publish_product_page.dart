import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/models/product.dart';
import 'package:trueke/features/products/providers/publish_product_provider.dart';
import '../../core/services/location_service.dart';

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image, required this.onRemove});
  final ImageProvider image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(
              image: image,
              width: 88,
              height: 98,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.inverseSurface.withAlpha(200),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 12,
                  color: theme.colorScheme.onInverseSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PublishProductPage extends ConsumerStatefulWidget {
  const PublishProductPage({super.key, this.product});
  final Product? product;

  @override
  ConsumerState<PublishProductPage> createState() => _PublishProductPageState();
}

class _PublishProductPageState extends ConsumerState<PublishProductPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _wantedController;
  late final TextEditingController _locationController;
  late final TextEditingController _priceController;

  static const _categories = [
    'Electrónica',
    'Moda',
    'Hogar',
    'Gaming',
    'Deporte',
    'Otros',
  ];
  static const _conditions = [
    'Nuevo',
    'Como nuevo',
    'Buen estado',
    'Con marcas de uso',
    'Para reparar',
  ];

  String _category = 'Electrónica';
  String _condition = 'Buen estado';
  TradeType _tradeType = TradeType.trade;
  double? _latitude;
  double? _longitude;
  final List<XFile> _selectedImages = [];
  final List<String> _existingImages = [];

  final RegExp _forbiddenWordsRegExp = RegExp(
    r'([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4})|'
    r'((?:\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{3,4})|'
    r'(\b[aá][\s\._-]*[rR][\s\._-]*[mM][\s\._-]*[aA]\b)|'
    r'(\b[dD][\s\._-]*[rR][\s\._-]*[oO][\s\._-]*[gG][\s\._-]*[aA]\b)|'
    r'(\b[eE][\s\._-]*[sS][\s\._-]*[tT][\s\._-]*[aA][\s\._-]*[fF][\s\._-]*[aA]\b)|'
    r'(\b[fF][\s\._-]*[aA][\s\._-]*[lL][\s\._-]*[sS][\s\._-]*[oOaA]\b)',
    caseSensitive: false,
  );

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _titleController = TextEditingController(text: product?.title);
    _descriptionController = TextEditingController(text: product?.description);
    _wantedController = TextEditingController(text: product?.wanted);
    _locationController = TextEditingController(text: product?.location);
    _priceController = TextEditingController(
      text: product?.price?.toStringAsFixed(0),
    );

    if (product != null) {
      _existingImages.addAll(product.images);
      _category = product.category;
      final String currentCond = product.condition;
      if (_conditions.contains(currentCond)) {
        _condition = currentCond;
      } else if (currentCond == 'Nueva') {
        _condition = 'Nuevo';
      } else if (currentCond == 'Usado') {
        _condition = 'Con marcas de uso';
      } else {
        _condition = 'Buen estado';
      }
      _tradeType = product.tradeType;
      _latitude = product.latitude;
      _longitude = product.longitude;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getCurrentLocation();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _wantedController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String? _validateModeration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    if (_forbiddenWordsRegExp.hasMatch(value)) {
      if (value.contains('@') ||
          RegExp(r'\d{6,}').hasMatch(value.replaceAll(RegExp(r'\s+'), ''))) {
        return 'Por seguridad, usa el chat de Trueke. No compartas teléfonos o emails.';
      }
      return 'Contenido inapropiado o término no permitido';
    }
    return null;
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (!mounted) return;
    if (image != null) {
      setState(() {
        if (!_selectedImages.any((selected) => selected.path == image.path)) {
          _selectedImages.add(image);
          ref
              .read(publishProductNotifierProvider.notifier)
              .setImages(_selectedImages.map((img) => File(img.path)).toList());
        }
      });
    }
  }

  void _removeSelectedImage(XFile image) {
    setState(() {
      _selectedImages.remove(image);
      if (_selectedImages.isEmpty) {
        ref.read(publishProductNotifierProvider.notifier).clearImages();
      } else {
        ref
            .read(publishProductNotifierProvider.notifier)
            .setImages(_selectedImages.map((img) => File(img.path)).toList());
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService().getCurrentLocation();
      if (position != null && mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          if (_locationController.text.isEmpty ||
              _locationController.text == 'Ubicación GPS establecida') {
            _locationController.text = 'Ubicación GPS establecida';
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = double.tryParse(
      _priceController.text.trim().replaceAll(',', '.'),
    );
    if (_tradeType != TradeType.trade && (price == null || price <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Introduce un precio mayor que cero.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final currentUserId = AuthService.currentUserId;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para publicar.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final publishNotifier = ref.read(publishProductNotifierProvider.notifier);

    if (widget.product != null) {
      await publishNotifier.updateExistingProduct(
        productId: widget.product!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: _tradeType == TradeType.trade ? null : price,
        category: _category,
        owner: widget.product!.owner,
        ownerId: currentUserId,
        condition: _condition,
        tradeType: _tradeType,
        wanted: _wantedController.text.trim(),
        location: _locationController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        existingImages: _existingImages,
        createdAt: widget.product!.createdAt,
      );
    } else {
      await publishNotifier.submitProduct(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: _tradeType == TradeType.trade ? null : price,
        category: _category,
        owner: 'Usuario',
        ownerId: currentUserId,
        condition: _condition,
        tradeType: _tradeType,
        wanted: _wantedController.text.trim(),
        location: _locationController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
      );
    }

    if (mounted) {
      final state = ref.read(publishProductNotifierProvider);
      if (state.isSuccess) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(publishProductNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product != null ? 'Editar Producto' : 'Publicar Producto',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: _validateModeration,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              validator: _validateModeration,
              maxLines: 3,
            ),
            DropdownButtonFormField<String>(
              initialValue: _category,
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _category = val!),
              decoration: const InputDecoration(labelText: 'Categoría'),
            ),
            DropdownButtonFormField<String>(
              initialValue: _condition,
              items: _conditions
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _condition = val!),
              decoration: const InputDecoration(labelText: 'Estado'),
            ),
            SegmentedButton<TradeType>(
              segments: const [
                ButtonSegment(value: TradeType.trade, label: Text('Trueque')),
                ButtonSegment(value: TradeType.sale, label: Text('Venta')),
              ],
              selected: {_tradeType},
              onSelectionChanged: (val) =>
                  setState(() => _tradeType = val.first),
            ),
            if (_tradeType == TradeType.sale)
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio (€)'),
                keyboardType: TextInputType.number,
              ),
            TextFormField(
              controller: _wantedController,
              decoration: const InputDecoration(
                labelText: '¿Qué buscas a cambio?',
              ),
            ),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Ubicación'),
            ),
            const SizedBox(height: 16),
            Wrap(
              children: [
                ..._existingImages.map(
                  (img) => _ImagePreview(
                    image: NetworkImage(img),
                    onRemove: () => setState(() => _existingImages.remove(img)),
                  ),
                ),
                ..._selectedImages.map(
                  (img) => _ImagePreview(
                    image: FileImage(File(img.path)),
                    onRemove: () => _removeSelectedImage(img),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: state.isPublishing ? null : _pickImages,
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Hacer Foto'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state.isPublishing ? null : _publish,
              child: state.isPublishing
                  ? const CircularProgressIndicator()
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
