import 'package:flutter/material.dart';
import 'package:parcial/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../application/providers/user_provider.dart';
import '../../../application/providers/image_provider.dart' as custom; // Evitamos conflicto con Flutter

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

  String? _uploadedPhotoUrl;
  final ImagePicker _picker = ImagePicker();


  @override
  void initState() {
    super.initState();
    // Pre-poblamos los campos con la información actual del usuario
    final user = context.read<UserProvider>().ownProfile;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _descriptionController = TextEditingController(text: user?.description ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _uploadedPhotoUrl = user?.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Método para seleccionar y subir la imagen en caliente al backend
  Future<void> _changePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;

    // Invocamos el ImageProvider para subirla
    final imageProvider = context.read<custom.ImageProvider>();
    final remoteUrl = await imageProvider.uploadImage(image.path);

    if (remoteUrl != null) {
      setState(() {
        _uploadedPhotoUrl = remoteUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen subida con éxito.')),
      );
    } else if (imageProvider.errorMessage != null) {
      _showError(imageProvider.errorMessage!);
    }
  }

  // HU-20 CA-4: Eliminar imagen subida si el usuario la quita
  Future<void> _removePhoto() async {
    if (_uploadedPhotoUrl == null) return;

    // Extraemos el filename UUID de la URL pública
    final filename = _uploadedPhotoUrl!.split('/').last;

    final imageProvider = context.read<custom.ImageProvider>();
    final success = await imageProvider.deleteImage(filename);

    if (success) {
      setState(() {
        _uploadedPhotoUrl = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen eliminada del servidor.')),
      );
    } else if (imageProvider.errorMessage != null) {
      _showError(imageProvider.errorMessage!);
    }
  }

  // Guardar todos los cambios combinados en el perfil propio (HU-05)
  Future<void> _saveChanges() async {
    final userProvider = context.read<UserProvider>();

    final success = await userProvider.updateProfile(
      fullName: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      photoUrl: _uploadedPhotoUrl, // Mandamos la nueva URL o null si se borró
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente.')),
      );
      Navigator.pop(context); // Volvemos atrás reflejando los cambios
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

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar adaptativo
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundImage: NetworkImage(_uploadedPhotoUrl != null && _uploadedPhotoUrl!.isNotEmpty
                      ? _uploadedPhotoUrl!
                      : AppConstants.defaultProfileImage),
                  child: isImageLoading ? const CircularProgressIndicator(color: Colors.white) : null,
                ),
                if (_uploadedPhotoUrl != null)
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.delete, size: 16, color: Colors.white),
                      onPressed: isImageLoading || isUserLoading ? null : _removePhoto,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
                onPressed: isImageLoading || isUserLoading ? null : _changePhoto,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Cambiar foto')
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
                onPressed: isImageLoading || isUserLoading ? null : _saveChanges,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: isUserLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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