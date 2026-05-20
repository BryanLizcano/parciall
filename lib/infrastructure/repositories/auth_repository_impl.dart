import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constants/api_config.dart';
import '../../domain/model/auth_session.dart';
import '../../domain/model/role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/dto/auth_request_dto.dart';
import '../../data/dto/auth_response_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FlutterSecureStorage _storage;
  AuthRepositoryImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'jwt_token';
  static const _roleKey = 'user_role';

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    final dto = LoginRequestDto(username: username, password: password);

    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200) {
      final authResponse = AuthResponseDto.fromJson(jsonDecode(response.body));
      await _saveSessionLocally(authResponse);
      return authResponse.toDomain();
    } else {
      throw Exception('Usuario o contraseña incorrectos');
    }
  }

  @override
  Future<AuthSession> register({
    required String username,
    required String password,
    required Role role,
  }) async {
    final dto = RegisterRequestDto(username: username, password: password, role: role);

    final response = await http.post(
      Uri.parse(ApiConfig.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final authResponse = AuthResponseDto.fromJson(jsonDecode(response.body));
      await _saveSessionLocally(authResponse);
      return authResponse.toDomain();
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Error en el registro');
    }
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
  }

  @override
  Future<String?> getStoredToken() async {
    return await _storage.read(key: _tokenKey);
  }

  @override
  Future<Role?> getStoredRole() async {
    final roleString = await _storage.read(key: _roleKey);
    if (roleString == 'ENTREPRENEUR') return Role.entrepreneur;
    if (roleString == 'CLIENT') return Role.client;
    return null;
  }

  Future<void> _saveSessionLocally(AuthResponseDto dto) async {
    await _storage.write(key: _tokenKey, value: dto.token);
    await _storage.write(key: _roleKey, value: dto.role.name.toUpperCase());
  }
}