import 'package:flutter/material.dart';
import '../../widgets/rating_stars.dart';

class ReviewsScreen extends StatelessWidget {
  static const routeName = '/reviews';
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos temporales — se cargarán con GetReviewsUseCase y GetReviewSummaryUseCase
    const placeholderReviews = [
      (name: 'Mariana Torres', rating: 5.0, comment: 'Excelente atención y muy buena presentación.', date: '12 Feb 2026'),
      (name: 'David Gómez',    rating: 4.5, comment: 'La experiencia fue clara y profesional.',      date: '28 Ene 2026'),
      (name: 'Paula Herrera',  rating: 4.8, comment: 'Muy buena comunicación y entrega cuidada.',    date: '14 Ene 2026'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Reseñas')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              children: [
                Text('Promedio general', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                // TODO: mostrar promedio real de ReviewSummary
                Text('--',
                    style: TextStyle(
                        fontSize: 34, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                RatingStars(rating: 0),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // TODO: mapear List<Review> del dominio
          ...placeholderReviews.map(
                (r) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(r.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                        ),
                        Text(r.date),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RatingStars(rating: r.rating),
                    const SizedBox(height: 8),
                    Text(r.comment),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}