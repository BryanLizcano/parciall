import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parcial/constants/app_constants.dart';
import 'package:provider/provider.dart';

import '../../../application/providers/auth_provider.dart';
import '../../../application/providers/user_provider.dart';
import '../../../domain/model/role.dart';
import '../auth/welcome_screen.dart';
import '../services/my_services_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'edit_profile_screen.dart';
import 'reviews_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadOwnProfile();
    });
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          WelcomeScreen.routeName,
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.ownProfile;

    // Interceptamos el botón físico de atrás del celular: en vez de hacer pop
    // (que llevaría a welcome y parecería que "cierra sesión"), minimizamos la app.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          // Minimizar la app en lugar de hacer pop
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        // automaticallyImplyLeading: false evita que AppBar muestre la flecha de retroceso
        appBar: AppBar(
          title: const Text('Mi perfil'),
          automaticallyImplyLeading: false,
        ),
        body: userProvider.isLoading && user == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: () => context.read<UserProvider>().loadOwnProfile(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28)),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundImage: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                          ? NetworkImage(user.photoUrl!)
                          : null,

                      child: user?.photoUrl == null || user!.photoUrl!.isEmpty
                          ? const Icon(Icons.person, size: 42) // Ajusta el tamaño para que quede bien con el radius 42
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.fullName ?? user?.username ?? 'Usuario',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: user?.role == Role.entrepreneur
                            ? const Color(0xFFEDE9FE)
                            : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        user?.role == Role.entrepreneur
                            ? 'Emprendedor'
                            : 'Cliente',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: user?.role == Role.entrepreneur
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFF16A34A),
                        ),
                      ),
                    ),
                    if (user?.description != null &&
                        user!.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        user.description!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(user?.address ?? 'Ubicación no configurada'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pushNamed(
                                context, EditProfileScreen.routeName),
                            child: const Text('Editar perfil'),
                          ),
                        ),
                        if (user?.role == Role.entrepreneur) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, MyServicesScreen.routeName),
                              child: const Text('Mis servicios'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _ProfileOption(
                icon: Icons.star_outline,
                title: 'Reseñas y calificaciones',
                onTap: () =>
                    Navigator.pushNamed(context, ReviewsScreen.routeName),
              ),
              _ProfileOption(
                  icon: Icons.settings_outlined,
                  title: 'Preferencias',
                  onTap: () {}),
              _ProfileOption(
                  icon: Icons.help_outline, title: 'Ayuda', onTap: () {}),
              _ProfileOption(
                icon: Icons.logout,
                title: 'Cerrar sesión',
                color: Colors.red.shade600,
                onTap: _confirmLogout,
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}