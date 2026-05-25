import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/providers/auth_provider.dart';
import '../../../application/providers/service_provider.dart';
import '../../../domain/model/role.dart';
import '../../theme/app_theme.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/section_title.dart';

class ServiceDetailScreen extends StatelessWidget {
  static const routeName = '/service-detail';
  const ServiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();
    final authProvider = context.watch<AuthProvider>();
    final service = serviceProvider.selectedService;

    // Estado de carga
    if (serviceProvider.isLoading && service == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Error al cargar
    if (service == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  serviceProvider.errorMessage ?? 'No se pudo cargar el servicio.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isOwnService =
        authProvider.currentSession?.username == service.entrepreneur.fullName;
    final isClient = authProvider.currentSession?.role == Role.client;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero con carrusel de imágenes ──────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: service.imageUrls.isEmpty
                  ? Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.image_outlined, size: 60, color: Colors.grey),
                ),
              )
                  : _ImageCarousel(imageUrls: service.imageUrls),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Título + estado ──────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          service.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                          AppTheme.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          service.category.name,
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Emprendedor ─────────────────────────────────────
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: service.entrepreneur.photoUrl != null
                            ? NetworkImage(service.entrepreneur.photoUrl!)
                            : null,
                        child: service.entrepreneur.photoUrl == null
                            ? const Icon(Icons.person, size: 18)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.entrepreneur.fullName ?? 'Emprendedor',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (service.entrepreneur.averageRating != null)
                              RatingStars(
                                rating: service.entrepreneur.averageRating!,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (service.address != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16,
                            color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            service.address!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ── Descripción ─────────────────────────────────────
                  const SectionTitle(title: 'Descripción'),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(service.description),
                  ),

                  // ── Galería adicional (si hay más de 1 imagen) ──────
                  if (service.imageUrls.length > 1) ...[
                    const SizedBox(height: 24),
                    const SectionTitle(title: 'Galería'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: service.imageUrls.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 12),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            service.imageUrls[i],
                            width: 130,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 130,
                              color: Colors.grey.shade200,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // ── Precio + acción ─────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Precio estimado',
                                style:
                                Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service.price != null
                                    ? '\$${service.price!.toStringAsFixed(0)}'
                                    : 'A convenir',
                                style:
                                Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                        // El botón de contactar solo aparece si el usuario
                        // es cliente (no puede chatear con sí mismo)
                        if (!isOwnService)
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/chat-room',
                                arguments: {
                                  'partnerId': service.entrepreneur.id,
                                  'partnerName': service.entrepreneur.fullName ?? 'Emprendedor',
                                },
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Contactar'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carrusel de imágenes ──────────────────────────────────────────────────────

class _ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  const _ImageCarousel({required this.imageUrls});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  int _current = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (_, i) => Image.network(
            widget.imageUrls[i],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          ),
        ),
        // Indicadores de página
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.imageUrls.asMap().entries.map((e) {
                return Container(
                  width: _current == e.key ? 18 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _current == e.key
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}