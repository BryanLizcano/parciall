import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
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
            onPressed: () => Navigator.pushNamed(context, CreateServiceScreen.routeName),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: mockServices.length,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ServiceCard(service: mockServices[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, CreateServiceScreen.routeName),
        label: const Text('Nuevo servicio'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
