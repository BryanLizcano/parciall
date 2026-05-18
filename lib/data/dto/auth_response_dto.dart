import '../../domain/model/auth_session.dart';
import '../../domain/model/role.dart';

class AuthResponseDto {
  final String token;
  final String username;
  final Role role;
  final bool success;

  const AuthResponseDto({
    required this.token,
    required this.username,
    required this.role,
    required this.success,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      token: json['token'],
      username: json['username'],
      // Mapeamos el string devuelto por el back al enum de Dart
      role: json['role'] == 'ENTREPRENEUR' ? Role.entrepreneur : Role.client,
      success: json['success'] ?? true,
    );
  }

  // Convertimos el DTO al modelo de dominio
  AuthSession toDomain() {
    return AuthSession(
      token: token,
      username: username,
      role: role,
    );
  }
}