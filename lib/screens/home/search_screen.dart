import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/service_card.dart';

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
              itemCount: categories.length,
              itemBuilder: (context, index) => CategoryChip(label: categories[index], selected: index == 2),
            ),
          ),
          const SizedBox(height: 24),
          ...mockServices.map((service) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ServiceCard(service: service),
              )),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}
