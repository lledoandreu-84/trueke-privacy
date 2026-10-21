import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trueke/core/theme/app_colors.dart';
import 'package:trueke/models/product.dart';

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
  late List<String> _images;
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
    _images = List.from(widget.product?.images ?? []);
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
        setState(() {
          _images.add(pickedFile.path);
        });
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
              'Añadir fotografía',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
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
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              ),
              title: const Text('Hacer una foto', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Usa la cámara de tu dispositivo', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              ),
              title: const Text('Subir desde galería', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Elige una imagen de tu galería', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isEditing ? 'Editar Producto' : 'Publicar Producto',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          children: [
            // 📸 1. Sección de Fotos Ultra Compacta
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fotos del artículo',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 75,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length + 1,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return InkWell(
                            onTap: _showImageSourceDialog,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 75,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMint,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 22),
                                  SizedBox(height: 4),
                                  Text(
                                    'Añadir',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final imgIndex = index - 1;
                        final imagePath = _images[imgIndex];
                        final isNetwork = imagePath.startsWith('http');

                        return Stack(
                          children: [
                            Container(
                              width: 75,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: isNetwork
                                  ? Image.network(
                                      imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: AppColors.surfaceMint,
                                        child: const Icon(Icons.image_outlined, color: AppColors.primary, size: 20),
                                      ),
                                    )
                                  : Image.file(
                                      File(imagePath),
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
                                    _images.removeAt(imgIndex);
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
                            if (imgIndex == 0)
                              Positioned(
                                bottom: 3,
                                left: 3,
                                right: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Portada',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w700),
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
            const SizedBox(height: 10),

            // 📝 2. Tarjeta de Información Básica (Agrupada)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      labelText: 'Título del artículo',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Categoría y Estado en la misma fila (2 columnas)
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Categoría',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: ['Electrónica', 'Moda', 'Hogar', 'Deportes', 'Otros']
                              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedCategory = val ?? 'Electrónica'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCondition,
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Estado',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: ['Nuevo', 'Como nuevo', 'Buen estado', 'Uso aceptable']
                              .map((cond) => DropdownMenuItem(value: cond, child: Text(cond, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedCondition = val ?? 'Buen estado'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 🔄 3. Modalidad & Trueke
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
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
                            padding: const EdgeInsets.symmetric(vertical: 9),
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isTrueque = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
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
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _seekingController,
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        labelText: '¿Qué buscas a cambio?',
                        hintText: 'Ej. Herramientas, videojuegos...',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🚀 4. Botón de Acción Principal Visualmente Directo
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Lógica de guardado
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEditing ? 'Guardar Cambios' : 'Publicar Artículo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
