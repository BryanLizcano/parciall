import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../application/providers/category_provider.dart';
import '../../../application/providers/service_provider.dart';
import '../../../application/providers/user_provider.dart';
import '../../../domain/model/service_summary.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/section_title.dart';
import '../home/search_screen.dart';
import '../services/service_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadOwnProfile();
      context.read<CategoryProvider>().loadCategories();
      context.read<ServiceProvider>().searchServices();
    });
  }

  void _filterByCategory(int? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    context.read<ServiceProvider>().searchServices(categoryId: categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().ownProfile;
    final categoryProvider = context.watch<CategoryProvider>();
    final serviceProvider = context.watch<ServiceProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<ServiceProvider>().searchServices(
                categoryId: _selectedCategoryId,
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Header ────────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, ${user?.fullName ?? user?.username ?? '...'}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Encuentra servicios cerca de ti',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user?.photoUrl == null || user!.photoUrl!.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Buscador ──────────────────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, SearchScreen.routeName),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Buscar diseño, tutorías, reparaciones...',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Categorías (HU-15) ────────────────────────────────────
                const SectionTitle(title: 'Categorías'),
                const SizedBox(height: 12),
                if (categoryProvider.isLoading)
                  const SizedBox(
                    height: 44,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else if (categoryProvider.categories.isEmpty &&
                    categoryProvider.errorMessage != null)
                  Row(
                    children: [
                      Text(
                        'Error al cargar categorías.',
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                      TextButton(
                        onPressed: () => categoryProvider.loadCategories(force: true),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryProvider.categories.length + 1,
                      itemBuilder: (ctx, index) {
                        if (index == 0) {
                          final isAll = _selectedCategoryId == null;
                          return _HomeCategoryChip(
                            label: 'Todos',
                            selected: isAll,
                            onTap: () => _filterByCategory(null),
                          );
                        }
                        final cat = categoryProvider.categories[index - 1];
                        final isSelected = _selectedCategoryId == cat.id;
                        return _HomeCategoryChip(
                          label: cat.name,
                          selected: isSelected,
                          onTap: () => _filterByCategory(isSelected ? null : cat.id),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 28),

                // ── Servicios destacados (HU-13) ──────────────────────────
                SectionTitle(
                  title: _selectedCategoryId == null ? 'Servicios destacados' : 'Resultados',
                  actionLabel: serviceProvider.searchTotalElements > 0 ? 'Ver todos' : null,
                ),
                const SizedBox(height: 16),

                if (serviceProvider.isLoading && serviceProvider.searchResults.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (serviceProvider.searchResults.isEmpty)
                  _EmptyServices(
                    onExplore: () => Navigator.pushNamed(context, SearchScreen.routeName),
                  )
                else
                  ...serviceProvider.searchResults.take(6).map(
                        (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _HomeServiceCard(
                        service: service,
                        onTap: () {
                          context.read<ServiceProvider>().loadServiceDetail(service.id);
                          Navigator.pushNamed(context, ServiceDetailScreen.routeName);
                        },
                      ),
                    ),
                  ),

                if (serviceProvider.searchResults.length > 6)
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, SearchScreen.routeName),
                      child: const Text('Ver todos los servicios →'),
                    ),
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      ),
    );
  }
}

class _HomeCategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _HomeCategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppTheme.primary : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _HomeServiceCard extends StatelessWidget {
  final ServiceSummary service;
  final VoidCallback onTap;

  const _HomeServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final thumbnail = service.thumbnail;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: thumbnail != null
                  ? Image.network(
                thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                  ),
                ),
              )
                  : Container(
                color: Colors.grey.shade100,
                child: const Center(
                  child: Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(service.category.name, style: Theme.of(context).textTheme.bodyMedium),
                  if (service.entrepreneurName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'por ${service.entrepreneurName}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (service.averageRating != null || service.entrepreneurRating != null)
                        RatingStars(
                          rating: service.averageRating ?? service.entrepreneurRating ?? 0,
                        ),
                      const Spacer(),
                      if (service.price != null)
                        Text(
                          '\$${service.price!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyServices extends StatelessWidget {
  final VoidCallback onExplore;
  const _EmptyServices({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No encontramos servicios en esta categoría.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onExplore,
              child: const Text('Explorar todos los servicios'),
            ),
          ],
        ),
      ),
    );
  }
}