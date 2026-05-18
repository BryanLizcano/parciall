import 'package:flutter/material.dart';
import '../../widgets/service_card.dart';
import 'create_service_screen.dart';

class MyServicesScreen extends StatelessWidget {
  static const routeName = '/my-services';
  const MyServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis servicios'),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, CreateServiceScreen.routeName),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          // TODO: cargar servicios reales con GetMyServicesUseCase
          ServiceCard(title: 'Diseño de logo profesional', category: 'Diseño', price: '\$150.000'),
          SizedBox(height: 16),
          ServiceCard(title: 'Kit de redes sociales', category: 'Diseño', price: '\$80.000'),
          SizedBox(height: 16),
          ServiceCard(title: 'Soporte técnico', category: 'Tecnología', active: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, CreateServiceScreen.routeName),
        label: const Text('Nuevo servicio'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}