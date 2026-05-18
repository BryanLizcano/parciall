import 'package:flutter/material.dart';
import '../../domain/model/auth_session.dart';
import '../../domain/model/role.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthSession? _currentSession;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository;

  AuthSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Verifica si el usuario ya había iniciado sesión al abrir la app
  Future<void> checkAuthStatus() async {
    final token = await _authRepository.getStoredToken();
    final role = await _authRepository.getStoredRole();

    if (token != null && role != null) {
      _currentSession = AuthSession(token: token, username: 'Usuario', role: role);
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    try {
      _currentSession = await _authRepository.login(
          username: username,
          password: password
      );
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String username, String password, Role role) async {
    _setLoading(true);
    try {
      _currentSession = await _authRepository.register(
          username: username,
          password: password,
          role: role
      );
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _currentSession = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}