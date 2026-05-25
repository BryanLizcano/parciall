import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  final List<String> _imageUrls = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;

  // GPS
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;

  int? _editingServiceId;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
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
      _latitude = selected.latitude;
      _longitude = selected.longitude;
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

  // ── GPS ───────────────────────────────────────────────────────────────────

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      // 1. Verificar si el servicio está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('El GPS está desactivado. Actívalo en la configuración del dispositivo.');
        return;
      }

      // 2. Verificar/pedir permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Permiso de ubicación denegado.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showError('Permiso de ubicación denegado permanentemente. Ve a Configuración > Aplicaciones para habilitarlo.');
        return;
      }

      // 3. Obtener posición
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ubicación capturada: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('No se pudo obtener la ubicación: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  void _clearLocation() {
    setState(() {
      _latitude = null;
      _longitude = null;
    });
  }

  // ── Imagen ────────────────────────────────────────────────────────────────

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

  Future<void> _removeImage(int index) async {
    final url = _imageUrls[index];
    final filename = url.split('/').last;
    final imageProvider = context.read<custom.ImageProvider>();
    await imageProvider.deleteImage(filename);
    if (!mounted) return;
    setState(() => _imageUrls.removeAt(index));
  }

  // ── Guardar ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      _showError('Selecciona una categoría.');
      return;
    }

    final serviceProvider = context.read<ServiceProvider>();
    final price = double.tryParse(_priceController.text.trim());
    final address = _addressController.text.trim().isEmpty
        ? null
        : _addressController.text.trim();

    if (_isEditMode && _editingServiceId != null) {
      final success = await serviceProvider.updateService(
        id: _editingServiceId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        price: price,
        address: address,
        latitude: _latitude,
        longitude: _longitude,
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
      final created = await serviceProvider.createService(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        price: price,
        address: address,
        latitude: _latitude,
        longitude: _longitude,
        imageUrls: _imageUrls,
      );
      if (!mounted) return;
      if (created != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Servicio publicado exitosamente.')),
        );
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final serviceProvider = context.watch<ServiceProvider>();
    final imageProvider = context.watch<custom.ImageProvider>();
    final isBusy = serviceProvider.isLoading ||
        _isUploadingImage ||
        imageProvider.isLoading ||
        _isGettingLocation;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar servicio' : 'Publicar servicio'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            // ── Galería de imágenes ──────────────────────────────────────
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

            // ── Categoría ─────────────────────────────────────────────────
            categoryProvider.isLoading
                ? const Center(heightFactor: 2, child: CircularProgressIndicator())
                : DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Categoría *'),
              items: categoryProvider.categories
                  .map((cat) => DropdownMenuItem(
                value: cat.id,
                child: Text(cat.name),
              ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
              validator: (v) => v == null ? 'Selecciona una categoría.' : null,
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
                      onPressed: () => categoryProvider.loadCategories(force: true),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // ── Precio ────────────────────────────────────────────────────
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio (opcional)',
                prefixText: '\$ ',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                if (double.tryParse(v.trim()) == null) return 'Ingresa un número válido.';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Ubicación con GPS ─────────────────────────────────────────
            _LocationSection(
              addressController: _addressController,
              latitude: _latitude,
              longitude: _longitude,
              isGettingLocation: _isGettingLocation,
              isBusy: isBusy,
              onGetLocation: _getCurrentLocation,
              onClearLocation: _clearLocation,
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
                        color: Colors.white, strokeWidth: 2),
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

// ── Widget de ubicación ───────────────────────────────────────────────────────

class _LocationSection extends StatelessWidget {
  final TextEditingController addressController;
  final double? latitude;
  final double? longitude;
  final bool isGettingLocation;
  final bool isBusy;
  final VoidCallback onGetLocation;
  final VoidCallback onClearLocation;

  const _LocationSection({
    required this.addressController,
    required this.latitude,
    required this.longitude,
    required this.isGettingLocation,
    required this.isBusy,
    required this.onGetLocation,
    required this.onClearLocation,
  });

  @override
  Widget build(BuildContext context) {
    final hasCoords = latitude != null && longitude != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: addressController,
          decoration: const InputDecoration(
            labelText: 'Dirección / Ciudad (opcional)',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
        ),
        const SizedBox(height: 10),

        // Botón GPS
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : onGetLocation,
                icon: isGettingLocation
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.my_location, size: 18),
                label: Text(
                  isGettingLocation
                      ? 'Obteniendo ubicación...'
                      : 'Usar mi ubicación actual (GPS)',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            if (hasCoords) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: onClearLocation,
                icon: const Icon(Icons.close, color: Colors.red),
                tooltip: 'Quitar coordenadas GPS',
              ),
            ],
          ],
        ),

        // Indicador de coordenadas capturadas
        if (hasCoords)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'GPS: ${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

// ── Widget galería ────────────────────────────────────────────────────────────

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
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
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