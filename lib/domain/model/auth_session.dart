import 'package:parcial/domain/model/role.dart';

/// Lo que el back devuelve tras login o registro exitoso.
/// El token se guarda en almacenamiento seguro; role decide la navegación.
class AuthSession {
  final String token;
  final String username;
  final Role role;

  const AuthSession({
    required this.token,
    required this.username,
    required this.role,
  });
}