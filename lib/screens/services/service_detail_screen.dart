import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/section_title.dart';

class ServiceDetailScreen extends StatelessWidget {
  static const routeName = '/service-detail';

  final MockService service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(background: Image.network(service.imageUrl, fit: BoxFit.cover)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 10),
                  Text(service.provider, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 10),
                  RatingStars(rating: service.rating),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined),
                      const SizedBox(width: 6),
                      Expanded(child: Text(service.location)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Text(service.description),
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'Galería'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(service.imageUrl, width: 140, fit: BoxFit.cover),
                      ),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: 3,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Precio estimado'),
                              const SizedBox(height: 4),
                              Text(service.price, style: Theme.of(context).textTheme.titleLarge),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('Contactar'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
