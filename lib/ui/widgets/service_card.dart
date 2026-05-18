import 'package:flutter/material.dart';
import '../screens/services/service_detail_screen.dart';
import '../theme/app_theme.dart';
import 'rating_stars.dart';

/// Widget de tarjeta de servicio.
/// TODO: recibir ServiceSummary del dominio cuando se implementen los repositorios.
class ServiceCard extends StatelessWidget {
  // Datos temporales hardcodeados para que compile sin errores
  final String title;
  final String category;
  final String price;
  final double rating;
  final String imageUrl;
  final String location;
  final bool active;

  const ServiceCard({
    super.key,
    this.title    = 'Servicio de ejemplo',
    this.category = 'Categoría',
    this.price    = '\$0',
    this.rating   = 0.0,
    this.imageUrl = 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3',
    this.location = 'Ubicación',
    this.active   = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, ServiceDetailScreen.routeName);
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(title,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: active
                          ? AppTheme.accent.withValues(alpha: 0.12)
                          : Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      active ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        color: active
                            ? AppTheme.accent
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(category),
              const SizedBox(height: 10),
              RatingStars(rating: rating),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18),
                  const SizedBox(width: 4),
                  Expanded(child: Text(location)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                price,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}