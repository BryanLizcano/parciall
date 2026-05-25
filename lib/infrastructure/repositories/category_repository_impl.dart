import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../constants/api_config.dart';
import '../../data/dto/category_dto.dart';
import '../../domain/model/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final http.Client _httpClient;

  CategoryRepositoryImpl({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// HU-15: endpoint público, no requiere JWT.
  @override
  Future<List<Category>> getAll() async {
    try {
      final response = await _httpClient.get(
        Uri.parse(ApiConfig.categories),
        headers: ApiConfig.jsonHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) =>
            CategoryDto.fromJson(json as Map<String, dynamic>).toDomain())
            .toList();
      } else {
        Map<String, dynamic>? errorBody;
        try {
          errorBody = jsonDecode(response.body);
        } catch (_) {}
        throw Exception(
            errorBody?['message'] ?? 'Error al cargar las categorías');
      }
    } on SocketException {
      throw Exception(
          'Sin conexión a internet. No se pudieron cargar las categorías.');
    } catch (e) {
      rethrow;
    }
  }
}