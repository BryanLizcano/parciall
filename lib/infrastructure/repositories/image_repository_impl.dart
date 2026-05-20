import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constants/api_config.dart';
import '../../domain/repositories/image_repository.dart';

class ImageRepositoryImpl implements ImageRepository {
  final FlutterSecureStorage _storage;

  ImageRepositoryImpl({required FlutterSecureStorage storage}) : _storage = storage;

  @override
  Future<String> upload(String filePath) async {
    final token = await _storage.read(key: 'jwt_token');

    // HU-20 CA-1: Petición de tipo multipart/form-data
    final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.uploadImage));

    // Adjuntamos el token de autenticación
    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    // Añadimos el archivo usando el campo "file" requerido por el backend
    request.files.add(
      await http.MultipartFile.fromPath('file', filePath),
    );

    // Enviamos la petición de flujo (streamed)
    final streamedResponse = await request.send();
    // Convertimos la respuesta del stream a una respuesta común y corriente
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['url'] as String; // Retornamos la URL pública devuelta
    } else {
      // Manejo de errores según las reglas del backend (Formato inválido, > 5MB, etc.)
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al subir la imagen al servidor');
    }
  }

  @override
  Future<void> delete(String filename) async {
    final token = await _storage.read(key: 'jwt_token');

    // HU-20 CA-10: DELETE requiere JWT y el filename en la URL
    final response = await http.delete(
      Uri.parse(ApiConfig.imageUrl(filename)),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    // El backend responde 204 No Content si se eliminó exitosamente
    if (response.statusCode != 204) {
      if (response.statusCode == 403) {
        throw Exception('No tienes permisos para eliminar esta imagen');
      } else if (response.statusCode == 404) {
        throw Exception('La imagen no existe en el servidor');
      } else {
        throw Exception('Error al eliminar la imagen del servidor');
      }
    }
  }
}