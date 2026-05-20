import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/api_config.dart';
import '../../data/dto/entrepreneur_profile_dto.dart';
import '../../data/dto/user_dto.dart';
import '../../domain/model/entrepreneur_profile.dart';
import '../../domain/model/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FlutterSecureStorage _storage;

  UserRepositoryImpl({required FlutterSecureStorage storage}) : _storage = storage;

  // Helper para construir los headers con el JWT Token de manera limpia
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<User> getOwnProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConfig.ownProfile),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final dto = UserDto.fromJson(jsonDecode(response.body));
      return dto.toDomain();
    } else {
      throw Exception('Error al obtener el perfil propio');
    }
  }

  @override
  Future<User> updateOwnProfile({
    String? fullName,
    String? photoUrl,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final headers = await _getHeaders();

    // Construimos el body dinámicamente omitiendo los valores nulos para no sobreescribir por error
    final Map<String, dynamic> bodyData = {};
    if (fullName != null) bodyData['fullName'] = fullName;
    if (photoUrl != null) bodyData['photoUrl'] = photoUrl;
    if (description != null) bodyData['description'] = description;
    if (address != null) bodyData['address'] = address;
    if (latitude != null) bodyData['latitude'] = latitude;
    if (longitude != null) bodyData['longitude'] = longitude;

    final response = await http.put(
      Uri.parse(ApiConfig.ownProfile),
      headers: headers,
      body: jsonEncode(bodyData),
    );

    if (response.statusCode == 200) {
      final dto = UserDto.fromJson(jsonDecode(response.body));
      return dto.toDomain();
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error al actualizar el perfil');
    }
  }

  @override
  Future<EntrepreneurProfile> getEntrepreneurProfile(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConfig.entrepreneurProfile(id)),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final dto = EntrepreneurProfileDto.fromJson(jsonDecode(response.body));
      return dto.toDomain();
    } else {
      throw Exception('Perfil de emprendedor no encontrado o ID no corresponde a un emprendedor');
    }
  }
}