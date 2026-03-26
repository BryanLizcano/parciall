import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../screens/services/service_detail_screen.dart';
import '../theme/app_theme.dart';
import 'rating_stars.dart';

class ServiceCard extends StatelessWidget {
  final MockService service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, ServiceDetailScreen.routeName, arguments: service);
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(service.imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: Text(service.title, style: Theme.of(context).textTheme.titleMedium)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: service.active ? AppTheme.accent.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      service.active ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        color: service.active ? AppTheme.accent : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(service.category),
              const SizedBox(height: 10),
              RatingStars(rating: service.rating),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18),
                  const SizedBox(width: 4),
                  Expanded(child: Text(service.location)),
                ],
              ),
              const SizedBox(height: 10),
              Text(service.price, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
