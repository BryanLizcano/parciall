import 'package:flutter/material.dart';
import '../../domain/repositories/image_repository.dart';

class ImageProvider extends ChangeNotifier {
  final ImageRepository _imageRepository;

  bool _isLoading = false;
  String? _errorMessage;

  ImageProvider({required ImageRepository imageRepository}) : _imageRepository = imageRepository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Sube la imagen y retorna la URL si tiene éxito, o null si falla.
  Future<String?> uploadImage(String filePath) async {
    _setLoading(true);
    try {
      _errorMessage = null;
      final url = await _imageRepository.upload(filePath);
      return url;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Elimina una imagen mediante su nombre de archivo (ej. "a1b2c3.jpg")
  Future<bool> deleteImage(String filename) async {
    _setLoading(true);
    try {
      _errorMessage = null;
      await _imageRepository.delete(filename);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}