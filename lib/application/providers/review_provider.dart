// lib/application/providers/review_provider.dart

import 'package:flutter/material.dart';
import '../../domain/model/review.dart';
import '../../domain/model/review_summary.dart';
import '../../domain/repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _reviewRepository;

  // HU-19: listado de reseñas con paginación
  List<Review> _reviews = [];
  int _currentPage = 0;
  bool _hasMore = false;

  // HU-19 CA-2: resumen/promedio
  ReviewSummary? _summary;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isSending = false;
  String? _errorMessage;

  ReviewProvider({required ReviewRepository reviewRepository})
      : _reviewRepository = reviewRepository;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<Review> get reviews => _reviews;
  ReviewSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSending => _isSending;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;

  // ── HU-19: Cargar reseñas + resumen de un emprendedor ────────────────────

  /// Carga simultáneamente el resumen y la primera página de reseñas.
  /// [loadMore] = true añade la siguiente página sin reiniciar la lista.
  Future<void> loadReviews(int entrepreneurId, {bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasMore) return;
      _isLoadingMore = true;
      notifyListeners();
    } else {
      // Nueva carga: reiniciamos todo el estado
      _reviews = [];
      _currentPage = 0;
      _hasMore = false;
      _summary = null;
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      // Cargamos el resumen en paralelo con las reseñas
      _loadSummary(entrepreneurId);
    }

    try {
      final result = await _reviewRepository.getReviews(
        entrepreneurId: entrepreneurId,
        page: _currentPage,
      );

      _reviews = loadMore ? [..._reviews, ...result.content] : result.content;
      _hasMore = result.hasNextPage;
      _currentPage = result.currentPage + 1;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> _loadSummary(int entrepreneurId) async {
    try {
      _summary = await _reviewRepository.getSummary(entrepreneurId);
      notifyListeners();
    } catch (_) {
      // No bloqueamos la UI si falla el resumen; las reseñas pueden mostrarse igual
    }
  }

  // ── HU-18: Crear reseña ───────────────────────────────────────────────────

  /// Devuelve true si la reseña fue enviada correctamente.
  Future<bool> createReview({
    required int entrepreneurId,
    required int servicePostId,
    required int rating,
    String? comment,
  }) async {
    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newReview = await _reviewRepository.createReview(
        entrepreneurId: entrepreneurId,
        servicePostId: servicePostId,
        rating: rating,
        comment: comment,
      );

      // Inserción optimista al inicio del listado
      _reviews = [newReview, ..._reviews];

      // Recargamos el resumen para reflejar el nuevo promedio
      _loadSummary(entrepreneurId);

      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // ── Utilidades ────────────────────────────────────────────────────────────

  void clearState() {
    _reviews = [];
    _summary = null;
    _currentPage = 0;
    _hasMore = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}