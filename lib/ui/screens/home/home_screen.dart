import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/user_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/section_title.dart';
import '../../widgets/service_card.dart';

const List<String> _placeholderCategories = [
  'Diseño',
  'Reparaciones',
  'Tutorías',
  'Tecnología',
  'Hogar',
  'Belleza',
];

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadOwnProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().ownProfile;

    // El botón físico de atrás minimiza la app en lugar de ir a WelcomeScreen
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
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
                        Text('Encuentra servicios cerca de ti',
                            style: Theme.of(context).textTheme.titleLarge),
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
              const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar diseño, tutorías, reparaciones...',
                ),
              ),
              const SizedBox(height: 24),
              const SectionTitle(title: 'Categorías'),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _placeholderCategories.length,
                  itemBuilder: (context, index) => CategoryChip(
                    label: _placeholderCategories[index],
                    selected: index == 0,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const SectionTitle(
                  title: 'Servicios destacados', actionLabel: 'Ver todos'),
              const SizedBox(height: 16),
              const ServiceCard(),
              const SizedBox(height: 16),
              const ServiceCard(
                  title: 'Clases de Matemáticas',
                  category: 'Tutorías',
                  price: '\$35.000/h'),
              const SizedBox(height: 16),
              const ServiceCard(
                  title: 'Soporte técnico',
                  category: 'Tecnología',
                  price: '\$70.000'),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      ),
    );
  }
}