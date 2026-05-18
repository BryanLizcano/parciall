class EntrepreneurProfile {
  final int id;
  final String? fullName;
  final String? photoUrl;
  final String? description;
  final String? address;
  final double? averageRating;
  final int totalReviews;

  const EntrepreneurProfile({
    required this.id,
    this.fullName,
    this.photoUrl,
    this.description,
    this.address,
    this.averageRating,
    required this.totalReviews,
  });
}