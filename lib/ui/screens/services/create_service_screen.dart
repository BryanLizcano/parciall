import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../application/providers/category_provider.dart';
import '../../../application/providers/image_provider.dart' as custom;
import '../../../application/providers/service_provider.dart';
import '../../theme/app_theme.dart';
import '../services/service_detail_screen.dart';

class CreateServiceScreen extends StatefulWidget {
  static const routeName = '/create-service';
  const CreateServiceScreen({super.key});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();

  int? _selectedCategoryId;
  // Lista de URLs ya subidas al backend (HU-20)
  final List<String> _imageUrls = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;

  // Modo edición: si se pasa un serviceId por arguments, cargamos sus datos
  int? _editingServiceId;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Carga categorías desde caché o backend (HU-15)
      context.read<CategoryProvider>().loadCategories();

      // Modo edición: pre-rellenamos si hay id en arguments
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        _editingServiceId = args;
        _isEditMode = true;
        _prefillFromSelected();
      }
    });
  }

  void _prefillFromSelected() {
    final selected = context.read<ServiceProvider>().selectedService;
    if (selected == null) return;
    setState(() {
      _titleController.text = selected.title;
      _descriptionController.text = selected.description;
      _priceController.text = selected.price?.toStringAsFixed(0) ?? '';
      _addressController.text = selected.address ?? '';
      _selectedCategoryId = selected.category.id;
      _imageUrls
        ..clear()
        ..addAll(selected.imageUrls);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ── Imagen: subir (HU-20) ─────────────────────────────────────────────────

  Future<void> _addImage() async {
    if (_imageUrls.length >= 5) {
      _showError('Máximo 5 imágenes por servicio.');
      return;
    }

    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) return;

    setState(() => _isUploadingImage = true);

    final imageProvider = context.read<custom.ImageProvider>();
    final url = await imageProvider.uploadImage(file.path);

    if (!mounted) return;
    setState(() => _isUploadingImage = false);

    if (url != null) {
      setState(() => _imageUrls.add(url));
    } else {
      _showError(imageProvider.errorMessage ?? 'Error al subir la imagen.');
    }
  }

  // ── Imagen: eliminar (HU-20) ──────────────────────────────────────────────

  Future<void> _removeImage(int index) async {
    final url = _imageUrls[index];
    final filename = url.split('/').last;

    final imageProvider = context.read<custom.ImageProvider>();
    // Eliminación silenciosa: quitamos de la lista aunque falle el backend
    await imageProvider.deleteImage(filename);
    if (!mounted) return;
    setState(() => _imageUrls.removeAt(index));
  }

  // ── Guardar / Publicar ────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      _showError('Selecciona una categoría.');
      return;
    }

    final serviceProvider = context.read<ServiceProvider>();
    final price = double.tryParse(_priceController.text.trim());

    if (_isEditMode && _editingServiceId != null) {
      // HU-09: Editar servicio existente
      final success = await serviceProvider.updateService(
        id: _editingServiceId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        price: price,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        imageUrls: _imageUrls,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Servicio actualizado correctamente.')),
        );
        Navigator.pop(context);
      } else {
        _showError(serviceProvider.errorMessage ?? 'Error al actualizar el servicio.');
      }
    } else {
      // HU-07: Crear nuevo servicio
      final created = await serviceProvider.createService(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        price: price,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        imageUrls: _imageUrls,
      );

      if (!mounted) return;

      if (created != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Servicio publicado exitosamente.')),
        );
        // HU-07 CA-6: navegar al detalle del servicio recién creado
        await serviceProvider.loadServiceDetail(created.id);
        if (mounted) {
          Navigator.pushReplacementNamed(context, ServiceDetailScreen.routeName);
        }
      } else {
        _showError(serviceProvider.errorMessage ?? 'Error al publicar el servicio.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final serviceProvider = context.watch<ServiceProvider>();
    final imageProvider = context.watch<custom.ImageProvider>();
    final isBusy = serviceProvider.isLoading || _isUploadingImage || imageProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar servicio' : 'Publicar servicio'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            // ── Galería de imágenes (HU-07 CA-3, HU-20) ─────────────────
            _ImageGallerySection(
              imageUrls: _imageUrls,
              isUploading: _isUploadingImage,
              onAdd: isBusy ? null : _addImage,
              onRemove: isBusy ? null : _removeImage,
            ),
            const SizedBox(height: 20),

            // ── Título ────────────────────────────────────────────────────
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Nombre del servicio *'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'El título es obligatorio.';
                if (v.trim().length < 5) return 'Mínimo 5 caracteres.';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Categoría (HU-15) ─────────────────────────────────────────
            categoryProvider.isLoading
                ? const Center(
              heightFactor: 2,
              child: CircularProgressIndicator(),
            )
                : DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Categoría *'),
              items: categoryProvider.categories
                  .map(
                    (cat) => DropdownMenuItem(
                  value: cat.id,
                  child: Text(cat.name),
                ),
              )
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
              validator: (v) =>
              v == null ? 'Selecciona una categoría.' : null,
            ),
            if (categoryProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Text(
                      categoryProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () =>
                          categoryProvider.loadCategories(force: true),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // ── Precio (opcional) ─────────────────────────────────────────
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio (opcional)',
                prefixText: '\$ ',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null; // opcional
                if (double.tryParse(v.trim()) == null) {
                  return 'Ingresa un número válido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Dirección (opcional) ──────────────────────────────────────
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Dirección / Ciudad (opcional)',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // ── Descripción ────────────────────────────────────────────────
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                alignLabelWithHint: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'La descripción es obligatoria.';
                if (v.trim().length < 20) return 'Mínimo 20 caracteres.';
                return null;
              },
            ),
            const SizedBox(height: 28),

            // ── Botón guardar ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isBusy ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: isBusy
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(_isEditMode ? 'Guardar cambios' : 'Publicar servicio'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widget galería de imágenes ────────────────────────────────────────────────

class _ImageGallerySection extends StatelessWidget {
  final List<String> imageUrls;
  final bool isUploading;
  final VoidCallback? onAdd;
  final void Function(int index)? onRemove;

  const _ImageGallerySection({
    required this.imageUrls,
    required this.isUploading,
    this.onAdd,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imágenes del servicio (máx. 5)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Imágenes ya subidas
              ...imageUrls.asMap().entries.map((entry) {
                final index = entry.key;
                final url = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          url,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 110,
                            height: 110,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      ),
                      // Botón eliminar imagen
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: onRemove != null ? () => onRemove!(index) : null,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Indicador de carga mientras sube
              if (isUploading)
                Container(
                  width: 110,
                  height: 110,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),

              // Botón agregar imagen
              if (imageUrls.length < 5 && !isUploading)
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.4),
                        width: 1.5,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            color: AppTheme.primary, size: 30),
                        SizedBox(height: 6),
                        Text(
                          'Agregar',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}