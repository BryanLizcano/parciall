// lib/data/dto/review_dto.dart

import '../../domain/model/review.dart';
import '../../domain/model/review_summary.dart';

// ── HU-18: body para crear una reseña ────────────────────────────────────────

class CreateReviewRequestDto {
  final int entrepreneurId;
  final int servicePostId;
  final int rating;
  final String? comment;

  const CreateReviewRequestDto({
    required this.entrepreneurId,
    required this.servicePostId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'entrepreneurId': entrepreneurId,
      'servicePostId': servicePostId,
      'rating': rating,
    };
    if (comment != null && comment!.isNotEmpty) map['comment'] = comment;
    return map;
  }
}

// ── HU-19: una reseña dentro del listado ─────────────────────────────────────

class ReviewDto {
  final int id;
  final int rating;
  final String? comment;
  final String createdAt;
  final String? clientFullName;
  final String? clientPhotoUrl;
  final int servicePostId;
  final String servicePostTitle;

  const ReviewDto({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.clientFullName,
    this.clientPhotoUrl,
    required this.servicePostId,
    required this.servicePostTitle,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    return ReviewDto(
      id: json['id'] as int? ?? 0,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] as String? ??
          json['created_at'] as String? ??
          DateTime.now().toIso8601String(),
      clientFullName: json['clientFullName'] as String?,
      clientPhotoUrl: json['clientPhotoUrl'] as String?,
      servicePostId: json['servicePostId'] as int? ?? 0,
      servicePostTitle: json['servicePostTitle'] as String? ?? '',
    );
  }

  Review toDomain() => Review(
    id: id,
    rating: rating,
    comment: comment,
    createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    clientFullName: clientFullName,
    clientPhotoUrl: clientPhotoUrl,
    servicePostId: servicePostId,
    servicePostTitle: servicePostTitle,
  );
}

// ── HU-19 CA-2: resumen de calificaciones ────────────────────────────────────

class ReviewSummaryDto {
  final double? averageRating;
  final int totalReviews;
  final Map<int, int> distribution;

  const ReviewSummaryDto({
    this.averageRating,
    required this.totalReviews,
    required this.distribution,
  });

  factory ReviewSummaryDto.fromJson(Map<String, dynamic> json) {
    // El backend puede devolver distribution como {"1":0,"2":1,"3":0,"4":2,"5":5}
    final dist = <int, int>{};
    final rawDist = json['distribution'] as Map<String, dynamic>?;
    if (rawDist != null) {
      for (final entry in rawDist.entries) {
        final key = int.tryParse(entry.key) ?? 0;
        final value = (entry.value as num?)?.toInt() ?? 0;
        if (key >= 1 && key <= 5) dist[key] = value;
      }
    }
    // Garantizamos que siempre existan las 5 claves aunque el back las omita
    for (int i = 1; i <= 5; i++) {
      dist.putIfAbsent(i, () => 0);
    }

    return ReviewSummaryDto(
      averageRating: json['averageRating'] != null
          ? (json['averageRating'] as num).toDouble()
          : null,
      totalReviews: json['totalReviews'] as int? ?? 0,
      distribution: dist,
    );
  }

  ReviewSummary toDomain() => ReviewSummary(
    averageRating: averageRating,
    totalReviews: totalReviews,
    distribution: distribution,
  );
}