import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  static const routeName = '/edit-profile';

  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 46,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1438761681033-6461ffad8d80'),
            ),
            TextButton.icon(onPressed: () {}, icon: const Icon(Icons.camera_alt_outlined), label: const Text('Cambiar foto')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Nombre')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Descripción')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Ubicación')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                child: const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Guardar cambios')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
