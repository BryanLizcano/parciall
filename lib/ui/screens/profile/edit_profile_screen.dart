import 'package:flutter/material.dart';
import 'package:parcial/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../application/providers/user_provider.dart';
import '../../../application/providers/image_provider.dart' as custom;

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/edit-profile';

  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;

  /// URL actualmente mostrada en el avatar. Puede ser la original del perfil,
  /// una recién subida, o null si el usuario la eliminó.
  String? _uploadedPhotoUrl;

  /// Guardamos la URL original del perfil para poder borrarla del backend
  /// si el usuario cambia la foto (evita acumulación de imágenes huérfanas).
  String? _originalPhotoUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().ownProfile;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _descriptionController = TextEditingController(text: user?.description ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _uploadedPhotoUrl = user?.photoUrl;
    _originalPhotoUrl = user?.photoUrl; // guardamos referencia original
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Extrae el nombre de archivo UUID de una URL pública del backend.
  /// Ej: "http://servidor/images/a1b2c3.jpg" → "a1b2c3.jpg"
  String? _filenameFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    // Solo intentamos borrar imágenes que pertenecen a nuestro backend
    if (!url.contains('/images/')) return null;
    return url.split('/').last;
  }

  /// Borra una imagen del backend de forma silenciosa (sin bloquear el flujo).
  Future<void> _deleteFromBackend(String? url) async {
    final filename = _filenameFromUrl(url);
    if (filename == null) return;
    // Ignoramos errores: si falla el borrado del backend no bloqueamos al usuario
    try {
      await context.read<custom.ImageProvider>().deleteImage(filename);
    } catch (_) {}
  }

  /// Fuerza la eliminación del caché de red para que el avatar refleje el
  /// nuevo estado inmediatamente sin tener que reiniciar la app.
  void _evictImageCache(String? url) {
    if (url == null || url.isEmpty) return;
    NetworkImage(url).evict();
  }

  Future<void> _changePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return;

    final imageProvider = context.read<custom.ImageProvider>();

    // 1. Subimos la nueva imagen primero
    final remoteUrl = await imageProvider.uploadImage(image.path);
    if (remoteUrl == null) {
      if (imageProvider.errorMessage != null) _showError(imageProvider.errorMessage!);
      return;
    }

    // 2. Borramos la imagen anterior del backend (la que estaba visible antes)
    //    para no dejar archivos huérfanos. Solo borramos si es diferente de la
    //    nueva URL (caso extremo de re-subir la misma imagen).
    if (_uploadedPhotoUrl != null && _uploadedPhotoUrl != remoteUrl) {
      await _deleteFromBackend(_uploadedPhotoUrl);
      _evictImageCache(_uploadedPhotoUrl);
    }

    // 3. Actualizamos el estado local con la nueva URL
    setState(() {
      _uploadedPhotoUrl = remoteUrl;
    });

    if (!mounted) return;
  }

  Future<void> _removePhoto() async {
    if (_uploadedPhotoUrl == null) return;

    final imageProvider = context.read<custom.ImageProvider>();
    final urlToDelete = _uploadedPhotoUrl!;

    final success = await imageProvider.deleteImage(
      _filenameFromUrl(urlToDelete) ?? urlToDelete.split('/').last,
    );

    if (!mounted) return;

    if (success) {
      // Limpiamos el caché para que el avatar deje de mostrar la imagen borrada
      _evictImageCache(urlToDelete);
      setState(() {
        _uploadedPhotoUrl = null;
      });
    } else if (imageProvider.errorMessage != null) {
      _showError(imageProvider.errorMessage!);
    }
  }

  Future<void> _saveChanges() async {
    final userProvider = context.read<UserProvider>();

    final success = await userProvider.updateProfile(
      fullName: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      photoUrl: _uploadedPhotoUrl,
    );

    if (!mounted) return;

    if (success) {
      // Si el usuario cambió la foto con éxito, la URL original ya fue borrada
      // durante _changePhoto(). Actualizamos _originalPhotoUrl para que una
      // segunda edición no intente borrar una URL que ya no existe.
      _originalPhotoUrl = _uploadedPhotoUrl;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente.')),
      );
      Navigator.pop(context);
    } else if (userProvider.errorMessage != null) {
      _showError(userProvider.errorMessage!);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isImageLoading = context.watch<custom.ImageProvider>().isLoading;
    final isUserLoading = context.watch<UserProvider>().isLoading;
    final isBusy = isImageLoading || isUserLoading;

    // Decidimos qué mostrar en el avatar:
    // - Si hay URL activa → esa imagen (con cache busting para forzar refresco)
    // - Si no → imagen por defecto
    final avatarUrl = (_uploadedPhotoUrl != null && _uploadedPhotoUrl!.isNotEmpty)
        ? _uploadedPhotoUrl!
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                // Usamos un ValueKey con la URL para forzar la reconstrucción
                // del widget cuando la URL cambia, evitando que Flutter reutilice
                // el NetworkImage cacheado con la URL anterior.
                CircleAvatar(
                  key: ValueKey(avatarUrl ?? 'default'),
                  radius: 46,
                  backgroundImage: NetworkImage(
                    avatarUrl ?? AppConstants.defaultProfileImage,
                  ),
                  child: isImageLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : null,
                ),
                if (avatarUrl != null)
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.delete, size: 16, color: Colors.white),
                      onPressed: isBusy ? null : _removePhoto,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: isBusy ? null : _changePhoto,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Cambiar foto'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre Completo'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descripción / Biografía'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Dirección física / Ciudad'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isBusy ? null : _saveChanges,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: isUserLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Guardar cambios'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}