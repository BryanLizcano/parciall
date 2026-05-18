import 'package:flutter/material.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/section_title.dart';

class ServiceDetailScreen extends StatelessWidget {
  static const routeName = '/service-detail';

  // TODO: recibir serviceId (int) y cargar con GetServiceDetailUseCase
  const ServiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos temporales de placeholder
    const imageUrl   = 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3';
    const title      = 'Servicio de ejemplo';
    const provider   = 'Emprendedor';
    const location   = 'Piedecuesta, Santander';
    const description = 'Descripción del servicio. Aquí irá la información real cuando se conecte al backend.';
    const price      = '\$0';
    const rating     = 0.0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 10),
                  Text(provider,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 10),
                  const RatingStars(rating: rating),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Icon(Icons.location_on_outlined),
                      SizedBox(width: 6),
                      Expanded(child: Text(location)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(description),
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
                        child: Image.network(
                          imageUrl,
                          width: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 140,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ),
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 12),
                      itemCount: 3,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Precio estimado'),
                              const SizedBox(height: 4),
                              Text(price,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge),
                            ],
                          ),
                        ),
                        // TODO: navegar al chat con el emprendedor
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