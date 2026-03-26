import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../widgets/rating_stars.dart';

class ReviewsScreen extends StatelessWidget {
  static const routeName = '/reviews';

  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reseñas')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: const Column(
              children: [
                Text('Promedio general', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('4.8', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                RatingStars(rating: 5),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...mockReviews.map((review) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(review.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                          Text(review.date),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RatingStars(rating: review.rating),
                      const SizedBox(height: 8),
                      Text(review.comment),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
