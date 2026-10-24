import 'package:trueke/shared/widgets/custom_app_bar.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trueke/core/theme/app_colors.dart';
import 'package:trueke/features/auth/auth_service.dart';
import 'package:trueke/features/products/providers/publish_product_provider.dart';
import 'package:trueke/models/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PublishProductPage extends ConsumerStatefulWidget {
  final Product? product;

  const PublishProductPage({super.key, this.product});

  @override
  ConsumerState<PublishProductPage> createState() => _PublishProductPageState();
}

class _PublishProductPageState extends ConsumerState<PublishProductPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _seekingController;
  
  late String _selectedCategory;
  late String _selectedCondition;
  late bool _isTrueque;
  late List<String> _existingImages;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _seekingController = TextEditingController(text: widget.product?.wanted ?? '');
    _selectedCategory = (widget.product?.category != null && widget.product!.category.isNotEmpty) 
        ? widget.product!.category 
        : 'Electrónica';
    _selectedCondition = (widget.product?.condition != null && widget.product!.condition.isNotEmpty) 
        ? widget.product!.condition 
        : 'Buen estado';
    _isTrueque = widget.product != null ? widget.product!.tradeType == TradeType.trade : true;
    _existingImages = List.from(widget.product?.images ?? []);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(publishProductProvider.notifier).clearImages();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _seekingController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        final publishState = ref.read(publishProductProvider);
        final currentFiles = List<File>.from(publishState.selectedImages);
        currentFiles.add(File(pickedFile.path));
        ref.read(publishProductProvider.notifier).setImages(currentFiles);
      }
    } catch (e) {
      debugPrint('Error al seleccionar imagen: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Añadir imagen',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 20),
              ),
              title: const Text('Tomar foto', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library_rounded, color: AppColors.primary, size: 20),
              ),
              title: const Text('Elegir de la galería', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final supabaseUser = Supabase.instance.client.auth.currentUser;
    final userId = supabaseUser?.id;
    String currentUsername = supabaseUser?.email?.split('@')[0] ?? 'Usuario';

    if (userId != null) {
      try {
        final profileData = await Supabase.instance.client
            .from('profiles')
            .select('username')
            .eq('id', userId)
            .maybeSingle();
        if (profileData != null && profileData['username'] != null && (profileData['username'] as String).isNotEmpty) {
          currentUsername = profileData['username'] as String;
        }
      } catch (_) {}
    }
    if (!mounted) return;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para publicar productos.'),
          backgroundColor: AppColors.textPrimary,
        ),
      );
      return;
    }

    final publishState = ref.read(publishProductProvider);
    if (_existingImages.isEmpty && publishState.selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes añadir al menos una foto del artículo.'),
          backgroundColor: AppColors.textPrimary,
        ),
      );
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final wanted = _seekingController.text.trim();
    const location = 'Madrid, España';
    const latitude = 40.416775;
    const longitude = -3.703790;
    final tradeType = _isTrueque ? TradeType.trade : TradeType.sale;

    final notifier = ref.read(publishProductProvider.notifier);

    if (widget.product != null) {
      await notifier.updateExistingProduct(
        productId: widget.product!.id,
        title: title,
        description: description,
        price: _isTrueque ? null : 0.0,
        category: _selectedCategory,
        owner: currentUsername,
        ownerId: userId,
        condition: _selectedCondition,
        tradeType: tradeType,
        wanted: wanted,
        location: location,
        latitude: latitude,
        longitude: longitude,
        existingImages: _existingImages,
        createdAt: widget.product!.createdAt,
      );
    } else {
      final supabaseUser = Supabase.instance.client.auth.currentUser;
      final dynamicOwnerId = supabaseUser?.id ?? userId;
      final dynamicOwnerName = supabaseUser?.userMetadata?['username'] ?? supabaseUser?.email?.split('@')[0] ?? currentUsername;

      await notifier.submitProduct(
        title: title,
        description: description,
        price: _isTrueque ? null : 0.0,
        category: _selectedCategory,
        owner: dynamicOwnerName,
        ownerId: dynamicOwnerId,
        condition: _selectedCondition,
        tradeType: tradeType,
        wanted: wanted,
        location: location,
        latitude: latitude,
        longitude: longitude,
      );
    }

    final finalState = ref.read(publishProductProvider);
    if (!mounted) return;

    if (finalState.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.product != null ? '¡Producto actualizado con éxito!' : '¡Artículo publicado con éxito!'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context, true);
    } else if (finalState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(finalState.errorMessage!),
          backgroundColor: AppColors.textPrimary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    final publishState = ref.watch(publishProductProvider);
    final selectedFiles = publishState.selectedImages;
    final totalImagesCount = _existingImages.length + selectedFiles.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        titleText: isEditing ? 'Editar Producto' : 'Publicar Producto',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          children: [
            // 1. BLOQUE DE DATOS PRINCIPALES
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TÍTULO
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      labelText: 'Título del artículo',
                      labelStyle: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa un título' : null,
                  ),
                  const SizedBox(height: 14),

                  // DESCRIPCIÓN (4 líneas)
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      labelStyle: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      alignLabelWithHint: true,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa una descripción' : null,
                  ),
                  const SizedBox(height: 14),

                  // CATEGORÍA Y ESTADO CON ETIQUETAS EXTERNAS (IMPOSIBLE SOLAPAR)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 4, bottom: 6),
                              child: Text(
                                'Categoría',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              dropdownColor: AppColors.surface,
                              isExpanded: true,
                              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: ['Electrónica', 'Moda', 'Hogar', 'Deportes', 'Otros']
                                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedCategory = val ?? 'Electrónica'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 4, bottom: 6),
                              child: Text(
                                'Estado',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCondition,
                              dropdownColor: AppColors.surface,
                              isExpanded: true,
                              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: ['Nuevo', 'Como nuevo', 'Buen estado', 'Uso aceptable']
                                  .map((cond) => DropdownMenuItem(value: cond, child: Text(cond, overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (val) => setState(() => _selectedCondition = val ?? 'Buen estado'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. FOTOS DEL ARTÍCULO (Diseño estándar armonizado con el formulario)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fotos del artículo',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: totalImagesCount + 1,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return InkWell(
                            onTap: _showImageSourceDialog,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 72,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 22),
                                  SizedBox(height: 3),
                                  Text(
                                    'Añadir',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final imgIndex = index - 1;
                        final bool isExisting = imgIndex < _existingImages.length;

                        return Stack(
                          children: [
                            Container(
                              width: 72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: isExisting
                                  ? Image.network(
                                      _existingImages[imgIndex],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: AppColors.surfaceMint,
                                        child: const Icon(Icons.image_outlined, color: AppColors.primary, size: 20),
                                      ),
                                    )
                                  : Image.file(
                                      selectedFiles[imgIndex - _existingImages.length],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: AppColors.surfaceMint,
                                        child: const Icon(Icons.image_outlined, color: AppColors.primary, size: 20),
                                      ),
                                    ),
                            ),
                            Positioned(
                              top: 3,
                              right: 3,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isExisting) {
                                      _existingImages.removeAt(imgIndex);
                                    } else {
                                      final localIdx = imgIndex - _existingImages.length;
                                      final updatedFiles = List<File>.from(selectedFiles);
                                      updatedFiles.removeAt(localIdx);
                                      ref.read(publishProductProvider.notifier).setImages(updatedFiles);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. MODALIDAD (Trueke / Venta)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isTrueque = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isTrueque ? AppColors.surfaceMint : AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isTrueque ? AppColors.primary : Colors.transparent,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Trueke',
                                style: TextStyle(
                                  color: _isTrueque ? AppColors.primary : AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isTrueque = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isTrueque ? AppColors.surfaceMint : AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: !_isTrueque ? AppColors.primary : Colors.transparent,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Venta',
                                style: TextStyle(
                                  color: !_isTrueque ? AppColors.primary : AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isTrueque) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _seekingController,
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        labelText: '¿Qué buscas a cambio?',
                        labelStyle: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                        hintText: 'Ej. Herramientas, videojuegos...',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // BOTÓN DE PUBLICAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: publishState.isPublishing ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: publishState.isPublishing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator.adaptive(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : Text(
                        isEditing ? 'Guardar Cambios' : 'Publicar Artículo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
