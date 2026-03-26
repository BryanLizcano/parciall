import 'package:flutter/material.dart';

import '../services/my_services_screen.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'edit_profile_screen.dart';
import 'reviews_screen.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1438761681033-6461ffad8d80'),
                ),
                const SizedBox(height: 14),
                Text('Camila Rodríguez', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                const Text('Emprendedora · Diseño gráfico'),
                const SizedBox(height: 6),
                const Text('Bogotá, Colombia'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushNamed(context, EditProfileScreen.routeName),
                        child: const Text('Editar perfil'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pushNamed(context, MyServicesScreen.routeName),
                        child: const Text('Mis servicios'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _ProfileOption(icon: Icons.star_outline, title: 'Reseñas y calificaciones', onTap: () => Navigator.pushNamed(context, ReviewsScreen.routeName)),
          _ProfileOption(icon: Icons.settings_outlined, title: 'Preferencias', onTap: () {}),
          _ProfileOption(icon: Icons.help_outline, title: 'Ayuda', onTap: () {}),
          _ProfileOption(icon: Icons.logout, title: 'Cerrar sesión', onTap: () {}),
        ],
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
