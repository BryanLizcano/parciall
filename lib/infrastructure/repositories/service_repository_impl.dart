import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../constants/api_config.dart';
import '../../data/dto/chat_dto.dart'; // PagedResultDto genérico ya existente
import '../../data/dto/service_dto.dart';
import '../../domain/model/map_marker.dart';
import '../../domain/model/paged_result.dart';
import '../../domain/model/service_post.dart';
import '../../domain/model/service_status.dart';
import '../../domain/model/service_summary.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/service_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final http.Client _httpClient;
  final AuthRepository _authRepository;

  ServiceRepositoryImpl({
    required AuthRepository authRepository,
    http.Client? httpClient,
  })  : _authRepository = authRepository,
        _httpClient = httpClient ?? http.Client();

  // ── Helper: headers autenticados ─────────────────────────────────────────

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authRepository.getStoredToken();
    if (token == null) throw Exception('Usuario no autenticado. Token ausente.');
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }

  // ── Helper: extrae mensaje de error del body ──────────────────────────────

  String _errorFrom(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['message'] as String? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  // ── HU-07: Crear servicio (POST /services) ────────────────────────────────

  @override
  Future<ServiceSummary> createService({
    required String title,
    required String description,
    required int categoryId,
    double? price,
    String? address,
    double? latitude,
    double? longitude,
    List<String> imageUrls = const [],
  }) async {
    try {
      final headers = await _getHeaders();
      final body = ServiceRequestDto(
        title: title,
        description: description,
        categoryId: categoryId,
        price: price,
        address: address,
        latitude: latitude,
        longitude: longitude,
        imageUrls: imageUrls,
      );

      final response = await _httpClient.post(
        Uri.parse(ApiConfig.services),
        headers: headers,
        body: jsonEncode(body.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServiceSummaryDto.fromJson(jsonDecode(response.body)).toDomain();
      }
      throw Exception(_errorFrom(response, 'Error al publicar el servicio'));
    } on SocketException {
      throw Exception('Sin conexión a internet.');
    } catch (e) {
      rethrow;
    }
  }

  // ── HU-08: Mis servicios (GET /services/my-services) ─────────────────────

  @override
  Future<List<ServiceSummary>> getMyServices() async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.get(
        Uri.parse(ApiConfig.myServices),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => ServiceSummaryDto.fromJson(
            json as Map<String, dynamic>)
            .toDomain())
            .toList();
      }
      throw Exception(_errorFrom(response, 'Error al cargar tus servicios'));
    } on SocketException {
      throw Exception('Sin conexión a internet.');
    } catch (e) {
      rethrow;
    }
  }

  // ── HU-09: Editar servicio (PUT /services/{id}) ───────────────────────────

  @override
  Future<ServiceSummary> updateService({
    required int id,
    required String title,
    required String description,
    required int categoryId,
    double? price,
    String? address,
    double? latitude,
    double? longitude,
    List<String> imageUrls = const [],
  }) async {
    try {
      final headers = await _getHeaders();
      final body = ServiceRequestDto(
        title: title,
        description: description,
        categoryId: categoryId,
        price: price,
        address: address,
        latitude: latitude,
        longitude: longitude,
        imageUrls: imageUrls,
      );

      final response = await _httpClient.put(
        Uri.parse(ApiConfig.serviceDetail(id)),
        headers: headers,
        body: jsonEncode(body.toJson()),
      );

      if (response.statusCode == 200) {
        return ServiceSummaryDto.fromJson(jsonDecode(response.body)).toDomain();
      }
      throw Exception(_errorFrom(response, 'Error al actualizar el servicio'));
    } on SocketException {
      throw Exception('Sin conexión a internet.');
    } catch (e) {
      rethrow;
    }
  }

  // ── HU-10: Eliminar servicio (DELETE /services/{id}) ─────────────────────

  @override
  Future<void> deleteService(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.delete(
        Uri.parse(ApiConfig.serviceDetail(id)),
        headers: headers,
      );

      if (response.statusCode == 204 || response.statusCode == 200) return;

      if (response.statusCode == 403) {
        throw Exception('No tienes permisos para eliminar este servicio');
      }
      if (response.statusCode == 404) {
        throw Exception('El servicio no existe');
      }
      throw Exception(_errorFrom(response, 'Error al eliminar el servicio'));
    } on SocketException {
      throw Exception('Sin conexión a internet.');
    } catch (e) {
      rethrow;
    }
  }

  // ── HU-11: Cambiar estado (PATCH /services/{id}/status) ──────────────────

  @override
  Future<ServiceSummary> changeStatus(int id, ServiceStatus status) async {
    try {
      final headers = await _getHeaders();
      final body = ServiceStatusRequestDto(status);

      final response = await _httpClient.patch(
        Uri.parse(ApiConfig.serviceStatus(id)),
        headers: headers,
        body: jsonEncode(body.toJson()),
      );

      if (response.statusCode == 200) {
        return ServiceSummaryDto.fromJson(jsonDecode(response.body)).toDomain();
      }
      throw Exception(
          _errorFrom(response, 'Error al cambiar el estado del servicio'));
    } on SocketException {
      throw Exception('Sin conexión a internet.');
    } catch (e) {
      rethrow;
    }
  }

  // ── HU-12: Detalle de servicio (GET /services/{id}) ──────────────────────

  @override
  Future<ServicePost> getServiceDetail(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.get(
        Uri.parse(ApiConfig.serviceDetail(id)),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ServicePostDto.fromJson(jsonDecode(response.body));
      }
      throw Exception(
          _errorFrom(response, 'Error al cargar el detalle del servicio'));
    } on SocketException {
      throw Exception('Sin conexión a internet.');
    } catch (e) {
      rethrow;
    }
  }

  // ── HU-13: Buscar servicios (GET /services?...) ───────────────────────────

  @override
  Future<PagedResult<ServiceSummary>> searchServices({
    int? categoryId,
    String? keyword,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final headers = await _getHeaders();

      final params = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };
      if (categoryId != null) params['categoryId'] = categoryId.toString();
      if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;

      final uri =
      Uri.parse(ApiConfig.services).replace(queryParameters: params);
      final response = await _httpClient.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final pagedDto = PagedResultDto.fromJson(jsonDecode(response.body));
        return pagedDto.toDomain(
              (item) => ServiceSummaryDto.fromJson(item as Map<String, dynamic>)
              .toDomain(),
        );
      }
      throw Exception(_errorFrom(response, 'Error al buscar servicios'));
    } on SocketException {
      throw Exception('Sin conexión a internet.');
    } catch (e) {
      rethrow;
    }
  }

  // ── HU-14: Marcadores del mapa (GET /services/map?...) ───────────────────

  @override
  Future<List<MapMarker>> getMapMarkers({
    required double lat,
    required double lng,
    double radiusKm = 10,
    int? categoryId,
  }) async {
    try {
      final headers = await _getHeaders();

      final params = <String, String>{
        'lat': lat.toString(),
        'lng': lng.toString(),
        'radiusKm': radiusKm.toString(),
      };
      if (categoryId != null) params['categoryId'] = categoryId.toString();

      final uri =
      Uri.parse(ApiConfig.servicesMap).replace(queryParameters: params);
      final response = await _httpClient.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) =>
            MapMarkerDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception(
          _errorFrom(response, 'Error al cargar los servicios del mapa'));
    } on SocketException {
      throw Exception('Sin conexión a internet.');
    } catch (e) {
      rethrow;
    }
  }
}