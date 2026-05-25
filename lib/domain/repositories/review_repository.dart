import '../model/paged_result.dart';
import '../model/review.dart';
import '../model/review_summary.dart';

abstract interface class ReviewRepository {
  /// HU-18: crea una reseña.
  Future<Review> createReview({
    required int entrepreneurId,
    required int servicePostId,
    required int rating,
    String? comment,
  });

  /// HU-19 CA-1: listado paginado de reseñas de un emprendedor.
  Future<PagedResult<Review>> getReviews({
    required int entrepreneurId,
    int page = 0,
    int size = 10,
  });

  /// HU-19 CA-2: resumen de calificaciones de un emprendedor.
  Future<ReviewSummary> getSummary(int entrepreneurId);
}
