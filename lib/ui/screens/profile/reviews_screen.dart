// lib/ui/screens/profile/reviews_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/providers/review_provider.dart';
import '../../../application/providers/user_provider.dart';
import '../../../domain/model/review.dart';
import '../../theme/app_theme.dart';
import '../../widgets/rating_stars.dart';

class ReviewsScreen extends StatefulWidget {
  static const routeName = '/reviews';

  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _scrollController = ScrollController();
  int? _entrepreneurId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // El ID puede venir como argumento de ruta (al ver el perfil de otro) o
    // lo tomamos del perfil propio si el emprendedor ve sus propias reseñas.
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _entrepreneurId = args;
    } else {
      _entrepreneurId =
          context.read<UserProvider>().ownProfile?.id;
    }

    if (_entrepreneurId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ReviewProvider>().loadReviews(_entrepreneurId!);
      });
    }

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_entrepreneurId != null) {
        context
            .read<ReviewProvider>()
            .loadReviews(_entrepreneurId!, loadMore: true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    context.read<ReviewProvider>().clearState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reseñas')),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_entrepreneurId != null) {
            await context
                .read<ReviewProvider>()
                .loadReviews(_entrepreneurId!);
          }
        },
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _entrepreneurId == null
            ? _ErrorState(
          message:
          'No se pudo determinar el perfil. Intenta de nuevo.',
          onRetry: () => Navigator.pop(context),
        )
            : ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            // ── Tarjeta resumen ──────────────────────────────
            _SummaryCard(provider: provider),
            const SizedBox(height: 20),

            // ── Lista de reseñas ─────────────────────────────
            if (provider.errorMessage != null)
              _ErrorState(
                message: provider.errorMessage!,
                onRetry: () => context
                    .read<ReviewProvider>()
                    .loadReviews(_entrepreneurId!),
              )
            else if (provider.reviews.isEmpty)
              _EmptyState()
            else ...[
                ...provider.reviews
                    .map((r) => _ReviewCard(review: r)),
                if (provider.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child:
                    Center(child: CircularProgressIndicator()),
                  ),
                if (!provider.hasMore && provider.reviews.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Has visto todas las reseñas',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
              ],
          ],
        ),
      ),
    );
  }
}

// ── Tarjeta de resumen / promedio ─────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final ReviewProvider provider;
  const _SummaryCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final summary = provider.summary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text('Promedio general',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          Text(
            summary?.averageRating != null
                ? summary!.averageRating!.toStringAsFixed(1)
                : '--',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          RatingStars(rating: summary?.averageRating ?? 0),
          const SizedBox(height: 6),
          Text(
            '${summary?.totalReviews ?? 0} reseña(s)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          // ── Barra de distribución (1★ a 5★) ──────────────────────────
          if (summary != null && summary.totalReviews > 0) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            ...List.generate(5, (i) {
              final star = 5 - i; // de 5 a 1
              final count = summary.distribution[star] ?? 0;
              final pct = summary.totalReviews > 0
                  ? count / summary.totalReviews
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text('$star',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.star_rounded,
                        color: AppTheme.warning, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.warning),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 24,
                      child: Text(
                        '$count',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// ── Tarjeta de reseña individual ──────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  String _formatDate(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabecera: avatar + nombre + fecha ──────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: review.clientPhotoUrl != null
                      ? NetworkImage(review.clientPhotoUrl!)
                      : null,
                  child: review.clientPhotoUrl == null
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    review.clientFullName ?? 'Cliente anónimo',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  _formatDate(review.createdAt),
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Estrellas ──────────────────────────────────────────────
            RatingStars(rating: review.rating.toDouble()),

            // ── Servicio referenciado ──────────────────────────────────
            if (review.servicePostTitle.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.storefront_outlined,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      review.servicePostTitle,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // ── Comentario ─────────────────────────────────────────────
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(review.comment!),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Estados vacío y de error ──────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.reviews_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Aún no hay reseñas.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Las reseñas de tus clientes aparecerán aquí.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 56, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}