import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class RatingStars extends StatelessWidget {
  final double rating;

  const RatingStars({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(index < rating.round() ? Icons.star_rounded : Icons.star_border_rounded, color: AppTheme.warning, size: 20);
        }),
        const SizedBox(width: 6),
        Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
