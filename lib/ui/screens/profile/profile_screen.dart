import 'package:flutter/material.dart';
import 'package:parcial/constants/app_constants.dart';
import 'package:provider/provider.dart';

import '../../../application/providers/user_provider.dart';
import '../../../domain/model/role.dart';
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
    // HU-04: Cargamos el perfil apenas entramos a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadOwnProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.ownProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: userProvider.isLoading && user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => context.read<UserProvider>().loadOwnProfile(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundImage: NetworkImage(user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                        ? user.photoUrl!
                        : AppConstants.defaultProfileImage),
                  ),
                  const SizedBox(height: 14),
                  // Mostramos nombre o el username si aún no se ha configurado el perfil
                  Text(
                      user?.fullName ?? user?.username ?? 'Usuario',
                      style: Theme.of(context).textTheme.titleLarge
                  ),
                  const SizedBox(height: 6),
                  // Mapeo dinámico del Rol
                  Text(user?.role == Role.entrepreneur
                      ? 'Emprendedor${user?.description != null ? ' · ' + user!.description! : ''}'
                      : 'Cliente'),
                  const SizedBox(height: 6),
                  Text(user?.address ?? 'Ubicación no configurada'),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushNamed(context, EditProfileScreen.routeName),
                          child: const Text('Editar perfil'),
                        ),
                      ),
                      // El botón "Mis servicios" solo tiene sentido si eres Emprendedor
                      if (user?.role == Role.entrepreneur) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.pushNamed(context, MyServicesScreen.routeName),
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
                onTap: () => Navigator.pushNamed(context, ReviewsScreen.routeName)
            ),
            _ProfileOption(icon: Icons.settings_outlined, title: 'Preferencias', onTap: () {}),
            _ProfileOption(icon: Icons.help_outline, title: 'Ayuda', onTap: () {}),
            _ProfileOption(
                icon: Icons.logout,
                title: 'Cerrar sesión',
                onTap: () {
                  // TODO: Invocar tu AuthProvider para limpiar almacenamiento y redirigir al Welcome
                }
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileOption({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}