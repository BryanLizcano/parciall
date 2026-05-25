// lib/infrastructure/repositories/review_repository_impl.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../constants/api_config.dart';
import '../../data/dto/chat_dto.dart'; // PagedResultDto genérico
import '../../data/dto/review_dto.dart';
import '../../domain/model/paged_result.dart';
import '../../domain/model/review.dart';
import '../../domain/model/review_summary.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final http.Client _httpClient;
  final AuthRepository _authRepository;

  ReviewRepositoryImpl({
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

  String _errorFrom(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['message'] as String? ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  // ── HU-18: Crear una reseña ───────────────────────────────────────────────

  @override
  Future<Review> createReview({
    required int entrepreneurId,
    required int servicePostId,
    required int rating,
    String? comment,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = CreateReviewRequestDto(
        entrepreneurId: entrepreneurId,
        servicePostId: servicePostId,
        rating: rating,
        comment: comment,
      );

      final response = await _httpClient.post(
        Uri.parse(ApiConfig.createReview),
        headers: headers,
        body: jsonEncode(body.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ReviewDto.fromJson(jsonDecode(response.body)).toDomain();
      }
      if (response.statusCode == 409) {
        throw Exception('Ya calificaste a este emprendedor por este servicio.');
      }
      if (response.statusCode == 403) {
        throw Exception('Solo puedes calificar emprendedores cuyos servicios hayas utilizado.');
      }
      throw Exception(_errorFrom(response, 'No se pudo enviar la reseña'));
    } on SocketException {
      throw Exception('Sin conexión a internet.');
    } catch (e) {
      rethrow;
    }
  }

  // ── HU-19 CA-1: Listado paginado de reseñas de un emprendedor ────────────

  @override
  Future<PagedResult<Review>> getReviews({
    required int entrepreneurId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final headers = await _getHeaders();

      final uri = Uri.parse(ApiConfig.entrepreneurReviews(entrepreneurId))
          .replace(queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      });

      final response = await _httpClient.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final pagedDto = PagedResultDto.fromJson(jsonDecode(response.body));
        return pagedDto.toDomain(
              (item) =>
              ReviewDto.fromJson(item as Map<String, dynamic>).toDomain(),
        );
      }
      throw Exception(_errorFrom(response, 'Error al cargar las reseñas'));
    } on SocketException {
      throw Exception('Sin conexión a internet.');
    } catch (e) {
      rethrow;
    }
  }

  // ── HU-19 CA-2: Resumen de calificaciones ────────────────────────────────

  @override
  Future<ReviewSummary> getSummary(int entrepreneurId) async {
    try {
      final headers = await _getHeaders();

      final response = await _httpClient.get(
        Uri.parse(ApiConfig.entrepreneurReviewsSummary(entrepreneurId)),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ReviewSummaryDto.fromJson(jsonDecode(response.body)).toDomain();
      }
      throw Exception(_errorFrom(response, 'Error al cargar el resumen de reseñas'));
    } on SocketException {
      throw Exception('Sin conexión a internet.');
    } catch (e) {
      rethrow;
    }
  }
}