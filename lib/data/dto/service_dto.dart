import '../../domain/model/category.dart';
import '../../domain/model/entrepreneur_summary.dart';
import '../../domain/model/map_marker.dart';
import '../../domain/model/service_post.dart';
import '../../domain/model/service_status.dart';
import '../../domain/model/service_summary.dart';

// ── Helpers privados ──────────────────────────────────────────────────────────

ServiceStatus _parseStatus(dynamic raw) =>
    (raw as String?)?.toUpperCase() == 'ACTIVE'
        ? ServiceStatus.active
        : ServiceStatus.inactive;

Category _parseCategory(Map<String, dynamic> json) =>
    Category(id: json['id'] as int, name: json['name'] as String);

List<String> _parseImageUrls(dynamic raw) =>
    (raw as List<dynamic>?)?.map((e) => e as String).toList() ?? [];

// ── HU-07, HU-09: body de crear/editar servicio ───────────────────────────────

class ServiceRequestDto {
  final String title;
  final String description;
  final int categoryId;
  final double? price;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<String> imageUrls;

  const ServiceRequestDto({
    required this.title,
    required this.description,
    required this.categoryId,
    this.price,
    this.address,
    this.latitude,
    this.longitude,
    this.imageUrls = const [],
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'imageUrls': imageUrls,
    };
    if (price != null) map['price'] = price;
    if (address != null) map['address'] = address;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    return map;
  }
}

// ── HU-11: body para cambiar estado ──────────────────────────────────────────

class ServiceStatusRequestDto {
  final ServiceStatus status;
  const ServiceStatusRequestDto(this.status);

  Map<String, dynamic> toJson() => {
    'status': status == ServiceStatus.active ? 'ACTIVE' : 'INACTIVE',
  };
}

// ── HU-08, HU-13: resumen de servicio ────────────────────────────────────────

class ServiceSummaryDto {
  final int id;
  final String title;
  final Map<String, dynamic> category;
  final String status;
  final double? price;
  final String createdAt;
  final List<String> imageUrls;
  final double? averageRating;

  // Presentes solo en resultados de búsqueda pública (HU-13)
  final String? entrepreneurName;
  final double? entrepreneurRating;

  const ServiceSummaryDto({
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

  factory ServiceSummaryDto.fromJson(Map<String, dynamic> json) {
    final cat = json['category'] as Map<String, dynamic>? ?? {'id': 0, 'name': ''};

    // El emprendedor puede venir como objeto nested o como campos planos,
    // dependiendo del endpoint (mis servicios vs búsqueda pública).
    String? entrepreneurName;
    double? entrepreneurRating;
    final ent = json['entrepreneur'] as Map<String, dynamic>?;
    if (ent != null) {
      entrepreneurName = ent['fullName'] as String?;
      entrepreneurRating = ent['averageRating'] != null
          ? (ent['averageRating'] as num).toDouble()
          : null;
    } else {
      entrepreneurName = json['entrepreneurName'] as String?;
      entrepreneurRating = json['entrepreneurRating'] != null
          ? (json['entrepreneurRating'] as num).toDouble()
          : null;
    }

    return ServiceSummaryDto(
      id: json['id'] as int,
      title: json['title'] as String,
      category: cat,
      status: json['status'] as String? ?? 'ACTIVE',
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      createdAt: json['createdAt'] as String,
      imageUrls: _parseImageUrls(json['imageUrls']),
      averageRating: json['averageRating'] != null
          ? (json['averageRating'] as num).toDouble()
          : null,
      entrepreneurName: entrepreneurName,
      entrepreneurRating: entrepreneurRating,
    );
  }

  ServiceSummary toDomain() => ServiceSummary(
    id: id,
    title: title,
    category: _parseCategory(category),
    status: _parseStatus(status),
    price: price,
    createdAt: DateTime.parse(createdAt),
    imageUrls: imageUrls,
    averageRating: averageRating,
    entrepreneurName: entrepreneurName,
    entrepreneurRating: entrepreneurRating,
  );
}

// ── HU-12: detalle completo de un servicio ────────────────────────────────────

class ServicePostDto {
  /// Parsea el JSON del backend directamente al modelo de dominio.
  static ServicePost fromJson(Map<String, dynamic> json) {
    final catMap =
        json['category'] as Map<String, dynamic>? ?? {'id': 0, 'name': ''};
    final entMap = json['entrepreneur'] as Map<String, dynamic>? ?? {};

    return ServicePost(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: _parseCategory(catMap),
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      status: _parseStatus(json['status']),
      address: json['address'] as String?,
      latitude:
      json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      imageUrls: _parseImageUrls(json['imageUrls']),
      entrepreneur: EntrepreneurSummary(
        id: entMap['id'] as int? ?? 0,
        fullName: entMap['fullName'] as String?,
        photoUrl: entMap['photoUrl'] as String?,
        averageRating: entMap['averageRating'] != null
            ? (entMap['averageRating'] as num).toDouble()
            : null,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

// ── HU-14: marcador ligero para el mapa ──────────────────────────────────────

class MapMarkerDto {
  /// Parsea el JSON del backend directamente al modelo de dominio.
  static MapMarker fromJson(Map<String, dynamic> json) {
    final catMap =
        json['category'] as Map<String, dynamic>? ?? {'id': 0, 'name': ''};
    final entMap = json['entrepreneur'] as Map<String, dynamic>?;

    return MapMarker(
      id: json['id'] as int,
      title: json['title'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      category: _parseCategory(catMap),
      entrepreneurFullName: entMap?['fullName'] as String?,
    );
  }
}