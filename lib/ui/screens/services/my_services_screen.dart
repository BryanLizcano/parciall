import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/providers/service_provider.dart';
import '../../../domain/model/service_status.dart';
import '../../../domain/model/service_summary.dart';
import '../../theme/app_theme.dart';
import 'create_service_screen.dart';
import '../services/service_detail_screen.dart';

class MyServicesScreen extends StatefulWidget {
  static const routeName = '/my-services';
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadMyServices();
    });
  }

  Future<void> _confirmDelete(BuildContext context, ServiceSummary service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar servicio'),
        content: Text(
          '¿Estás seguro que deseas eliminar "${service.title}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<ServiceProvider>();
      final success = await provider.deleteService(service.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Servicio eliminado correctamente.'
                  : provider.errorMessage ?? 'Error al eliminar.',
            ),
            backgroundColor: success ? null : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleStatus(BuildContext context, ServiceSummary service) async {
    final provider = context.read<ServiceProvider>();
    final newStatus = service.status == ServiceStatus.active
        ? ServiceStatus.inactive
        : ServiceStatus.active;

    final success = await provider.changeStatus(service.id, newStatus);
    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Error al cambiar el estado.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis servicios'),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, CreateServiceScreen.routeName);
              // Recargamos la lista al regresar del formulario de creación
              if (mounted) context.read<ServiceProvider>().loadMyServices();
            },
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Nuevo servicio',
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (provider.isLoading && provider.myServices.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!provider.isLoading && provider.myServices.isEmpty) {
            return _EmptyState(
              onTap: () async {
                await Navigator.pushNamed(context, CreateServiceScreen.routeName);
                if (mounted) context.read<ServiceProvider>().loadMyServices();
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ServiceProvider>().loadMyServices(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: provider.myServices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (ctx, index) {
                final service = provider.myServices[index];
                return _ServiceManagementCard(
                  service: service,
                  onToggleStatus: () => _toggleStatus(context, service),
                  onEdit: () async {
                    await Navigator.pushNamed(
                      context,
                      CreateServiceScreen.routeName,
                      arguments: service.id, // pasamos el id para modo edición
                    );
                    if (mounted) context.read<ServiceProvider>().loadMyServices();
                  },
                  onDelete: () => _confirmDelete(context, service),
                  onTap: () {
                    context.read<ServiceProvider>().loadServiceDetail(service.id);
                    Navigator.pushNamed(context, ServiceDetailScreen.routeName);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, CreateServiceScreen.routeName);
          if (mounted) context.read<ServiceProvider>().loadMyServices();
        },
        label: const Text('Nuevo servicio'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

// ── Tarjeta de gestión de servicio ───────────────────────────────────────────

class _ServiceManagementCard extends StatelessWidget {
  final ServiceSummary service;
  final VoidCallback onToggleStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _ServiceManagementCard({
    required this.service,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = service.status == ServiceStatus.active;
    final thumbnail = service.thumbnail;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            if (thumbnail != null)
              Image.network(
                thumbnail,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PlaceholderImage(height: 140),
              )
            else
              _PlaceholderImage(height: 140),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título + chip de estado
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(isActive: isActive),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    service.category.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (service.price != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '\$${service.price!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Controles: toggle + editar + eliminar
                  Row(
                    children: [
                      // Toggle activo/inactivo (HU-11)
                      Row(
                        children: [
                          Switch.adaptive(
                            value: isActive,
                            onChanged: (_) => onToggleStatus(),
                            activeColor: AppTheme.accent,
                          ),
                          Text(
                            isActive ? 'Activo' : 'Inactivo',
                            style: TextStyle(
                              color: isActive
                                  ? AppTheme.accent
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Editar (HU-09)
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Editar',
                        color: AppTheme.primary,
                      ),
                      // Eliminar (HU-10)
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Eliminar',
                        color: Colors.red,
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

class _StatusChip extends StatelessWidget {
  final bool isActive;
  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.accent.withValues(alpha: 0.12)
            : Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: isActive ? AppTheme.accent : Colors.grey.shade700,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final double height;
  const _PlaceholderImage({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 40, color: Colors.grey),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_outlined, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              'Aún no tienes servicios',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Publica tu primer servicio para que los clientes puedan encontrarte.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.add),
              label: const Text('Publicar mi primer servicio'),
            ),
          ],
        ),
      ),
    );
  }
}