import 'package:parcial/domain/model/map_marker.dart';
import 'package:parcial/domain/model/paged_result.dart';
import 'package:parcial/domain/model/service_post.dart';
import 'package:parcial/domain/model/service_status.dart';
import 'package:parcial/domain/model/service_summary.dart';

abstract interface class ServiceRepository {
  /// HU-07: publica un nuevo servicio.
  /// [imageUrls] son URLs obtenidas previamente de ImageRepository.upload().
  Future<ServiceSummary> createService({
    required String title,
    required String description,
    required int categoryId,
    double? price,
    String? address,
    double? latitude,
    double? longitude,
    List<String> imageUrls,
  });

  /// HU-08: lista todos los servicios del emprendedor autenticado.
  Future<List<ServiceSummary>> getMyServices();

  /// HU-09: edita un servicio existente.
  Future<ServiceSummary> updateService({
    required int id,
    required String title,
    required String description,
    required int categoryId,
    double? price,
    String? address,
    double? latitude,
    double? longitude,
    List<String> imageUrls,
  });

  /// HU-10: elimina un servicio.
  Future<void> deleteService(int id);

  /// HU-11: cambia el estado activo/inactivo.
  Future<ServiceSummary> changeStatus(int id, ServiceStatus status);

  /// HU-12: detalle completo de un servicio.
  Future<ServicePost> getServiceDetail(int id);

  /// HU-13: búsqueda paginada de servicios activos.
  Future<PagedResult<ServiceSummary>> searchServices({
    int? categoryId,
    String? keyword,
    int page = 0,
    int size = 20,
  });

  /// HU-14: marcadores del mapa dentro de un radio.
  Future<List<MapMarker>> getMapMarkers({
    required double lat,
    required double lng,
    double radiusKm = 10,
    int? categoryId,
  });
}