// Una reseña dentro del listado del emprendedor (HU-19).
class Review {
  final int id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? clientFullName;
  final String? clientPhotoUrl;
  final int servicePostId;
  final String servicePostTitle;

  const Review({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.clientFullName,
    this.clientPhotoUrl,
    required this.servicePostId,
    required this.servicePostTitle,
  });
}