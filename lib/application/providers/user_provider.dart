import 'package:flutter/material.dart';
import '../../domain/model/entrepreneur_profile.dart';
import '../../domain/model/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  User? _ownProfile;
  EntrepreneurProfile? _selectedEntrepreneurProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProvider({required UserRepository userRepository}) : _userRepository = userRepository;

  User? get ownProfile => _ownProfile;
  EntrepreneurProfile? get selectedEntrepreneurProfile => _selectedEntrepreneurProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // HU-04: Cargar perfil propio
  Future<void> loadOwnProfile() async {
    _setLoading(true);
    try {
      _ownProfile = await _userRepository.getOwnProfile();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // HU-05: Actualizar perfil propio
  Future<bool> updateProfile({
    String? fullName,
    String? photoUrl,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    _setLoading(true);
    try {
      // Actualizamos en backend y refrescamos el estado local de _ownProfile
      _ownProfile = await _userRepository.updateOwnProfile(
        fullName: fullName,
        photoUrl: photoUrl,
        description: description,
        address: address,
        latitude: latitude,
        longitude: longitude,
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

  // HU-06: Ver perfil público de otro emprendedor
  Future<void> loadEntrepreneurProfile(int id) async {
    _setLoading(true);
    try {
      _selectedEntrepreneurProfile = await _userRepository.getEntrepreneurProfile(id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}