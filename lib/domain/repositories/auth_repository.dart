// lib/domain/repositories/auth_repository.dart

import 'package:parcial/domain/model/auth_session.dart';
import 'package:parcial/domain/model/role.dart';

/// Puerto de autenticación.
/// La implementación concreta vive en infrastructure/repositories/.
abstract interface class AuthRepository {
  /// HU-02: inicia sesión y devuelve la sesión con token.
  Future<AuthSession> login({
    required String username,
    required String password,
  });

  /// HU-01: registra un nuevo usuario.
  Future<AuthSession> register({
    required String username,
    required String password,
    required Role role,
  });

  /// HU-03: elimina la sesión local (token en almacenamiento seguro).
  Future<void> logout();

  /// Devuelve el token almacenado localmente, o null si no hay sesión.
  Future<String?> getStoredToken();

  /// Devuelve el rol almacenado localmente, o null si no hay sesión.
  Future<Role?> getStoredRole();
}