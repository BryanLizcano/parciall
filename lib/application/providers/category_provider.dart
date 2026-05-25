import 'package:flutter/material.dart';
import '../../domain/model/category.dart';
import '../../domain/repositories/category_repository.dart';

/// Gestiona las categorías del sistema (HU-15).
/// Las cachea en memoria durante la sesión para no repetir la petición.
class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _categoryRepository;

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _loaded = false; // flag de caché

  CategoryProvider({required CategoryRepository categoryRepository})
      : _categoryRepository = categoryRepository;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasCategories => _categories.isNotEmpty;

  /// HU-15: carga categorías desde el backend.
  /// Si ya fueron cargadas previamente no vuelve a hacer la petición
  /// a menos que [force] sea true (útil para pull-to-refresh).
  Future<void> loadCategories({bool force = false}) async {
    if (_loaded && !force) return; // caché válido

    _setLoading(true);
    try {
      _categories = await _categoryRepository.getAll();
      _errorMessage = null;
      _loaded = true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}