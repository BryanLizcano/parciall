// Payload ligero para el mapa (HU-14).
import 'category.dart';

class MapMarker {
  final int id;
  final String title;
  final double latitude;
  final double longitude;
  final Category category;
  final String? entrepreneurFullName;

  const MapMarker({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.entrepreneurFullName,
  });
}