import '../../domain/model/role.dart';

class LoginRequestDto {
  final String username;
  final String password;

  const LoginRequestDto({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}

class RegisterRequestDto {
  final String username;
  final String password;
  final Role role;

  const RegisterRequestDto({
    required this.username,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    // Convertimos el enum a texto en mayúsculas para que Jackson en Spring lo entienda
    'role': role.name.toUpperCase(),
  };
}