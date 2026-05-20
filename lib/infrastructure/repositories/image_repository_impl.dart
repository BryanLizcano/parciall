import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constants/api_config.dart';
import '../../domain/repositories/image_repository.dart';

class ImageRepositoryImpl implements ImageRepository {
  final FlutterSecureStorage _storage;

  ImageRepositoryImpl({required FlutterSecureStorage storage})
      : _storage = storage;

  /// Detecta el Content-Type correcto.
  /// image_picker en Android devuelve paths temporales con nombres UUID
  /// sin extensión legible, entonces fromPath() no puede inferir el mimetype
  /// y envía application/octet-stream → el backend rechaza con 400.
  /// Solución: extensión primero, magic bytes como respaldo.
  MediaType _detectMediaType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      default:
      // Respaldo: magic bytes
        try {
          final bytes = File(filePath).readAsBytesSync();
          if (bytes.length >= 3 &&
              bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
            return MediaType('image', 'jpeg'); // FF D8 FF → JPEG
          }
          if (bytes.length >= 4 &&
              bytes[0] == 0x89 && bytes[1] == 0x50 &&
              bytes[2] == 0x4E && bytes[3] == 0x47) {
            return MediaType('image', 'png'); // 89 50 4E 47 → PNG
          }
          if (bytes.length >= 12 &&
              bytes[0] == 0x52 && bytes[1] == 0x49 &&
              bytes[8] == 0x57 && bytes[9] == 0x45 &&
              bytes[10] == 0x42 && bytes[11] == 0x50) {
            return MediaType('image', 'webp'); // RIFF....WEBP
          }
        } catch (_) {
          // No se pudo leer — fallback
        }
        return MediaType('image', 'jpeg'); // galería casi siempre es jpeg
    }
  }

  @override
  Future<String> upload(String filePath) async {
    final token = await _storage.read(key: 'jwt_token');
    final mediaType = _detectMediaType(filePath);

    final request =
    http.MultipartRequest('POST', Uri.parse(ApiConfig.uploadImage));

    request.headers['Authorization'] = 'Bearer $token';

    // Forzamos el contentType para que Spring Boot lo acepte correctamente
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: mediaType,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['url'] as String;
    } else {
      Map<String, dynamic>? errorBody;
      try {
        errorBody = jsonDecode(response.body);
      } catch (_) {}
      throw Exception(
          errorBody?['message'] ?? 'Error al subir la imagen (${response.statusCode})');
    }
  }

  @override
  Future<void> delete(String filename) async {
    final token = await _storage.read(key: 'jwt_token');

    final response = await http.delete(
      Uri.parse(ApiConfig.imageUrl(filename)),
      headers: {'Authorization': 'Bearer $token'},
    );

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