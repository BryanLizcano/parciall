import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/section_title.dart';
import '../../widgets/service_card.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hola, Camila', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 4),
                      Text('Encuentra servicios cerca de ti', style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                ),
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1438761681033-6461ffad8d80'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar diseño, tutorías, reparaciones...',
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle(title: 'Categorías'),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) => CategoryChip(label: categories[index], selected: index == 0),
              ),
            ),
            const SizedBox(height: 28),
            const SectionTitle(title: 'Servicios destacados', actionLabel: 'Ver todos'),
            const SizedBox(height: 16),
            ...mockServices.map((service) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ServiceCard(service: service),
                )),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }
}
