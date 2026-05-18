import 'package:flutter/material.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/service_card.dart';

const List<String> _placeholderCategories = [
  'Diseño',
  'Reparaciones',
  'Tutorías',
  'Tecnología',
  'Hogar',
  'Belleza',
];

class SearchScreen extends StatelessWidget {
  static const routeName = '/search';
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar servicios')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: 'Busca por categoría o nombre del servicio',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _placeholderCategories.length,
              itemBuilder: (context, index) => CategoryChip(
                label: _placeholderCategories[index],
                selected: index == 2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // TODO: cargar con SearchServicesUseCase
          const ServiceCard(),
          const SizedBox(height: 16),
          const ServiceCard(title: 'Clases de Matemáticas', category: 'Tutorías'),
          const SizedBox(height: 16),
          const ServiceCard(title: 'Soporte técnico', category: 'Tecnología'),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}