import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/providers/category_provider.dart';
import '../../../application/providers/service_provider.dart';
import '../../../domain/model/service_summary.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/rating_stars.dart';
import '../services/service_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
      context.read<ServiceProvider>().searchServices();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<ServiceProvider>().searchServices(
          categoryId: _selectedCategoryId,
          keyword: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          loadMore: true,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    context.read<ServiceProvider>().clearSearchResults();
    super.dispose();
  }

  void _search({int? categoryId, bool resetCategory = false}) {
    if (resetCategory) {
      setState(() => _selectedCategoryId = null);
    } else if (categoryId != null) {
      setState(() => _selectedCategoryId = categoryId);
    }

    context.read<ServiceProvider>().searchServices(
      categoryId: resetCategory ? null : (categoryId ?? _selectedCategoryId),
      keyword: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final serviceProvider = context.watch<ServiceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar servicios')),
      body: Column(
        children: [
          // ── Barra de búsqueda ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Busca por nombre o descripción…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _search();
                  },
                )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // ── Chips de categorías ────────────────────────────────────────
          if (categoryProvider.categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categoryProvider.categories.length + 1,
                  itemBuilder: (ctx, index) {
                    if (index == 0) {
                      final isAll = _selectedCategoryId == null;
                      return _CategoryChipButton(
                        label: 'Todos',
                        selected: isAll,
                        onTap: () => _search(resetCategory: true),
                      );
                    }
                    final cat = categoryProvider.categories[index - 1];
                    final isSelected = _selectedCategoryId == cat.id;
                    return _CategoryChipButton(
                      label: cat.name,
                      selected: isSelected,
                      onTap: () => isSelected
                          ? _search(resetCategory: true)
                          : _search(categoryId: cat.id),
                    );
                  },
                ),
              ),
            ),

          const SizedBox(height: 14),

          // ── Contador de resultados ─────────────────────────────────────
          if (!serviceProvider.isLoading || serviceProvider.searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${serviceProvider.searchTotalElements} servicio(s) encontrado(s)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),

          const SizedBox(height: 10),

          // ── Lista de resultados ────────────────────────────────────────
          Expanded(
            child: Builder(
              builder: (_) {
                if (serviceProvider.isLoading && serviceProvider.searchResults.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!serviceProvider.isLoading && serviceProvider.searchResults.isEmpty) {
                  return _EmptySearch(
                    hasFilters: _selectedCategoryId != null || _searchController.text.isNotEmpty,
                    onClear: () {
                      _searchController.clear();
                      _search(resetCategory: true);
                    },
                  );
                }

                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: serviceProvider.searchResults.length +
                      (serviceProvider.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (ctx, index) {
                    if (index == serviceProvider.searchResults.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final service = serviceProvider.searchResults[index];
                    return _SearchResultCard(
                      service: service,
                      onTap: () {
                        context.read<ServiceProvider>().loadServiceDetail(service.id);
                        Navigator.pushNamed(context, ServiceDetailScreen.routeName);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}

class _CategoryChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChipButton({required this.label, required this.selected, required this.onTap});

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

class _SearchResultCard extends StatelessWidget {
  final ServiceSummary service;
  final VoidCallback onTap;

  const _SearchResultCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final thumbnail = service.thumbnail;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: thumbnail != null
                  ? Image.network(
                thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PlaceholderThumb(),
              )
                  : _PlaceholderThumb(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (service.averageRating != null || service.entrepreneurRating != null) ...[
                          RatingStars(
                            rating: service.averageRating ?? service.entrepreneurRating ?? 0,
                          ),
                          const Spacer(),
                        ],
                        if (service.price != null)
                          Text(
                            '\$${service.price!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderThumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.grey, size: 30),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClear;

  const _EmptySearch({required this.hasFilters, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              hasFilters
                  ? 'No encontramos servicios con estos filtros.'
                  : 'No hay servicios disponibles.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onClear, child: const Text('Limpiar filtros')),
            ],
          ],
        ),
      ),
    );
  }
}