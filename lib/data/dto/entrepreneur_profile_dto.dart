import '../../domain/model/entrepreneur_profile.dart';

class EntrepreneurProfileDto {
  final int id;
  final String? fullName;
  final String? photoUrl;
  final String? description;
  final String? address;
  final double? averageRating;
  final int totalReviews;

  const EntrepreneurProfileDto({
    required this.id,
    this.fullName,
    this.photoUrl,
    this.description,
    this.address,
    this.averageRating,
    required this.totalReviews,
  });

  factory EntrepreneurProfileDto.fromJson(Map<String, dynamic> json) {
    return EntrepreneurProfileDto(
      id: json['id'],
      fullName: json['fullName'],
      photoUrl: json['photoUrl'],
      description: json['description'],
      address: json['address'],
      averageRating: json['averageRating'] != null ? (json['averageRating'] as num).toDouble() : null,
      totalReviews: json['totalReviews'] ?? 0,
    );
  }

  EntrepreneurProfile toDomain() {
    return EntrepreneurProfile(
      id: id,
      fullName: fullName,
      photoUrl: photoUrl,
      description: description,
      address: address,
      averageRating: averageRating,
      totalReviews: totalReviews,
    );
  }
}