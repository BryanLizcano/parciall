import 'category.dart';
import 'entrepreneur_summary.dart';
import 'service_status.dart';

class ServicePost {
  final int id;
  final String title;
  final String description;
  final Category category;
  final double? price;
  final ServiceStatus status;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<String> imageUrls;
  final EntrepreneurSummary entrepreneur;
  final DateTime createdAt;

  const ServicePost({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.price,
    required this.status,
    this.address,
    this.latitude,
    this.longitude,
    required this.imageUrls,
    required this.entrepreneur,
    required this.createdAt,
  });
}
