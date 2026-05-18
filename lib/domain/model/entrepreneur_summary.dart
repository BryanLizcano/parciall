class EntrepreneurSummary {
  final int id;
  final String? fullName;
  final String? photoUrl;
  final double? averageRating;

  const EntrepreneurSummary({
    required this.id,
    this.fullName,
    this.photoUrl,
    this.averageRating,
  });
}