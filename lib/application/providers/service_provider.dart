import 'package:flutter/material.dart';
import '../../domain/model/map_marker.dart';
import '../../domain/model/service_post.dart';
import '../../domain/model/service_status.dart';
import '../../domain/model/service_summary.dart';
import '../../domain/repositories/service_repository.dart';

/// Gestiona el estado de servicios para HU-07 a HU-14.
class ServiceProvider extends ChangeNotifier {
  final ServiceRepository _serviceRepository;

  // HU-08: servicios propios del emprendedor
  List<ServiceSummary> _myServices = [];

  // HU-12: detalle del servicio actualmente seleccionado
  ServicePost? _selectedService;

  // HU-13: resultados de búsqueda con soporte de paginación (load more)
  List<ServiceSummary> _searchResults = [];
  int _currentSearchPage = 0;
  bool _hasMoreResults = false;
  int _searchTotalElements = 0;

  // HU-14: marcadores del mapa
  List<MapMarker> _mapMarkers = [];

  // Estado de carga dual: _isLoading bloquea la UI completa;
  // _isLoadingMore se usa en scroll infinito (HU-13 CA-5) sin bloquear.
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  ServiceProvider({required ServiceRepository serviceRepository})
      : _serviceRepository = serviceRepository;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<ServiceSummary> get myServices => _myServices;
  ServicePost? get selectedService => _selectedService;
  List<ServiceSummary> get searchResults => _searchResults;
  bool get hasMoreResults => _hasMoreResults;
  int get searchTotalElements => _searchTotalElements;
  List<MapMarker> get mapMarkers => _mapMarkers;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;

  // ── HU-07: Publicar un servicio ───────────────────────────────────────────

  /// Devuelve el [ServiceSummary] creado, o null si ocurrió un error.
  /// La UI puede usar el id del resultado para navegar al detalle (HU-07 CA-6).
  Future<ServiceSummary?> createService({
    required String title,
    required String description,
    required int categoryId,
    double? price,
    String? address,
    double? latitude,
    double? longitude,
    List<String> imageUrls = const [],
  }) async {
    _setLoading(true);
    try {
      final created = await _serviceRepository.createService(
        title: title,
        description: description,
        categoryId: categoryId,
        price: price,
        address: address,
        latitude: latitude,
        longitude: longitude,
        imageUrls: imageUrls,
      );
      // Inserción optimista al inicio para que aparezca al tope de la lista
      _myServices = [created, ..._myServices];
      _errorMessage = null;
      return created;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ── HU-08: Ver mis servicios ──────────────────────────────────────────────

  Future<void> loadMyServices() async {
    _setLoading(true);
    try {
      _myServices = await _serviceRepository.getMyServices();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // ── HU-09: Editar un servicio ─────────────────────────────────────────────

  Future<bool> updateService({
    required int id,
    required String title,
    required String description,
    required int categoryId,
    double? price,
    String? address,
    double? latitude,
    double? longitude,
    List<String> imageUrls = const [],
  }) async {
    _setLoading(true);
    try {
      final updated = await _serviceRepository.updateService(
        id: id,
        title: title,
        description: description,
        categoryId: categoryId,
        price: price,
        address: address,
        latitude: latitude,
        longitude: longitude,
        imageUrls: imageUrls,
      );
      // Actualización optimista en la lista local
      _myServices = _myServices.map((s) => s.id == id ? updated : s).toList();
      // Invalidamos el detalle en caché para forzar recarga la próxima vez
      if (_selectedService?.id == id) _selectedService = null;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── HU-10: Eliminar un servicio ───────────────────────────────────────────

  Future<bool> deleteService(int id) async {
    _setLoading(true);
    try {
      await _serviceRepository.deleteService(id);
      // Eliminación optimista: quitamos de la lista local inmediatamente
      _myServices = _myServices.where((s) => s.id != id).toList();
      if (_selectedService?.id == id) _selectedService = null;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── HU-11: Cambiar estado activo/inactivo ─────────────────────────────────

  Future<bool> changeStatus(int id, ServiceStatus status) async {
    _setLoading(true);
    try {
      final updated = await _serviceRepository.changeStatus(id, status);
      // Actualización optimista: reemplazamos solo el item modificado
      _myServices = _myServices.map((s) => s.id == id ? updated : s).toList();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── HU-12: Ver detalle de un servicio ─────────────────────────────────────

  Future<void> loadServiceDetail(int id) async {
    _setLoading(true);
    try {
      _selectedService = await _serviceRepository.getServiceDetail(id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // ── HU-13: Buscar servicios con paginación ────────────────────────────────

  /// Busca servicios activos con filtros opcionales.
  ///
  /// [loadMore] = false (default): nueva búsqueda, reinicia la lista.
  /// [loadMore] = true: agrega la siguiente página a los resultados actuales
  /// (scroll infinito — HU-13 CA-5).
  Future<void> searchServices({
    int? categoryId,
    String? keyword,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (!_hasMoreResults) return; // ya no hay más páginas
      _isLoadingMore = true;
      notifyListeners();
    } else {
      // Nueva búsqueda: reiniciamos todo el estado de paginación
      _searchResults = [];
      _currentSearchPage = 0;
      _hasMoreResults = false;
      _searchTotalElements = 0;
      _isLoading = true;
      notifyListeners();
    }

    try {
      final result = await _serviceRepository.searchServices(
        categoryId: categoryId,
        keyword: keyword,
        page: _currentSearchPage,
      );

      _searchResults = loadMore
          ? [..._searchResults, ...result.content]
          : result.content;

      _searchTotalElements = result.totalElements;
      _hasMoreResults = result.hasNextPage;
      // Preparamos la página siguiente para el próximo llamado loadMore
      _currentSearchPage = result.currentPage + 1;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ── HU-14: Marcadores del mapa ────────────────────────────────────────────

  Future<void> loadMapMarkers({
    required double lat,
    required double lng,
    double radiusKm = 10,
    int? categoryId,
  }) async {
    _setLoading(true);
    try {
      _mapMarkers = await _serviceRepository.getMapMarkers(
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
        categoryId: categoryId,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  // ── Utilidades ────────────────────────────────────────────────────────────

  /// Limpia el servicio seleccionado al salir del detalle.
  void clearSelectedService() {
    _selectedService = null;
    notifyListeners();
  }

  /// Limpia el estado de búsqueda (útil al abandonar la pantalla de búsqueda).
  void clearSearchResults() {
    _searchResults = [];
    _currentSearchPage = 0;
    _hasMoreResults = false;
    _searchTotalElements = 0;
    notifyListeners();
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