import 'package:flutter/material.dart';

class CreateServiceScreen extends StatelessWidget {
  static const routeName = '/create-service';

  const CreateServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar servicio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 54),
                  SizedBox(height: 8),
                  Text('Zona visual para cargar imágenes'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const TextField(decoration: InputDecoration(labelText: 'Nombre del servicio')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Categoría')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Precio')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Ubicación')),
            const SizedBox(height: 16),
            const TextField(maxLines: 4, decoration: InputDecoration(labelText: 'Descripción')),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                    child: const Text('Estado: Activo'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    child: const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Guardar visual')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
