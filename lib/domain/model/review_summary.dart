// Resumen de calificaciones de un emprendedor (HU-19 CA-2).
class ReviewSummary {
  final double? averageRating;
  final int totalReviews;
  // Claves 1..5, siempre presentes (valor 0 si no hay).
  final Map<int, int> distribution;

  const ReviewSummary({
    this.averageRating,
    required this.totalReviews,
    required this.distribution,
  });
}