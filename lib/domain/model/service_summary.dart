import 'package:parcial/domain/model/category.dart';
import 'package:parcial/domain/model/service_status.dart';

class ServiceSummary {
  final int id;
  final String title;
  final Category category;
  final ServiceStatus status;
  final double? price;
  final DateTime createdAt;
  final List<String> imageUrls;
  final double? averageRating;
  // Solo presente en búsqueda pública (HU-13)
  final String? entrepreneurName;
  final double? entrepreneurRating;

  const ServiceSummary({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    this.price,
    required this.createdAt,
    required this.imageUrls,
    this.averageRating,
    this.entrepreneurName,
    this.entrepreneurRating,
  });

  /// Thumbnail: primera imagen o null.
  String? get thumbnail => imageUrls.isEmpty ? null : imageUrls.first;
}